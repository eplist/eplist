#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"

ROOT = File.expand_path("..", __dir__)
PLACEHOLDER_PATTERN = /<[^>]+>/

errors = []

def load_yaml(path, errors)
  YAML.load_file(path)
rescue Psych::Exception => e
  errors << "#{File.basename(path)}: invalid YAML: #{e.message}"
  nil
end

def string_value?(value)
  value.is_a?(String) && !value.strip.empty?
end

Dir.chdir(ROOT) do
  unless File.file?("index.yml")
    errors << "index.yml: missing file"
  end

  yaml_files = Dir["*.yml"].sort
  provider_files = yaml_files - ["index.yml"]
  loaded = {}

  yaml_files.each do |file|
    loaded[file] = load_yaml(file, errors)
  end

  index = loaded["index.yml"]
  indexed_files = []
  slugs = Set.new
  index_files = Set.new

  if index
    errors << "index.yml: version must be v1" unless index["version"] == "v1"

    providers = index["providers"]
    if providers.is_a?(Array)
      providers.each_with_index do |provider, index_position|
        label = "index.yml providers[#{index_position}]"
        unless provider.is_a?(Hash)
          errors << "#{label}: must be a mapping"
          next
        end

        slug = provider["slug"]
        display_name = provider["display-name"]
        file = provider["file"]

        errors << "#{label}: missing slug" unless string_value?(slug)
        errors << "#{label}: missing display-name" unless string_value?(display_name)
        errors << "#{label}: missing file" unless string_value?(file)

        next unless string_value?(file)

        if file.include?("/") || file.include?("\\")
          errors << "#{label}: file must be a root-level YAML filename"
        end

        unless file.end_with?(".yml")
          errors << "#{label}: file must end with .yml"
        end

        if index_files.include?(file)
          errors << "#{label}: duplicate file #{file}"
        else
          index_files.add(file)
        end

        if string_value?(slug)
          if slugs.include?(slug)
            errors << "#{label}: duplicate slug #{slug}"
          else
            slugs.add(slug)
          end
        end

        unless File.file?(file)
          errors << "#{label}: referenced file #{file} does not exist"
          next
        end

        indexed_files << file
        provider_data = loaded[file]
        provider_slug = provider_data&.dig("metameta", "name")
        if string_value?(slug) && provider_slug != slug
          errors << "#{label}: slug #{slug} does not match #{file} metameta.name #{provider_slug.inspect}"
        end
      end
    else
      errors << "index.yml: providers must be an array"
    end
  end

  missing_from_index = provider_files - indexed_files
  extra_in_index = indexed_files - provider_files
  errors << "index.yml: missing provider files #{missing_from_index.join(', ')}" unless missing_from_index.empty?
  errors << "index.yml: references non-provider files #{extra_in_index.join(', ')}" unless extra_in_index.empty?

  endpoints = {}

  provider_files.each do |file|
    data = loaded[file]
    next unless data

    errors << "#{file}: version must be v1" unless data["version"] == "v1"

    meta = data["metameta"]
    if meta.is_a?(Hash)
      errors << "#{file}: metameta.name is required" unless string_value?(meta["name"])
      errors << "#{file}: metameta.official-doc is required" unless string_value?(meta["official-doc"])
    else
      errors << "#{file}: metameta must be a mapping"
    end

    provider_endpoints = data["endpoints"]
    unless provider_endpoints.is_a?(Array) && !provider_endpoints.empty?
      errors << "#{file}: endpoints must be a non-empty array"
      next
    end

    provider_endpoints.each_with_index do |entry, endpoint_position|
      label = "#{file} endpoints[#{endpoint_position}]"
      unless entry.is_a?(Hash)
        errors << "#{label}: must be a mapping"
        next
      end

      region = entry["region"]
      endpoint = entry["endpoint"]

      errors << "#{label}: region is required" unless string_value?(region)
      errors << "#{label}: endpoint is required" unless string_value?(endpoint)

      [[:region, region], [:endpoint, endpoint]].each do |field, value|
        next unless string_value?(value)

        errors << "#{label}: #{field} contains a placeholder" if value.match?(PLACEHOLDER_PATTERN)
        errors << "#{label}: #{field} has surrounding whitespace" if value != value.strip
      end

      next unless string_value?(endpoint)

      if endpoints.key?(endpoint)
        errors << "#{label}: duplicate endpoint #{endpoint} already defined in #{endpoints[endpoint]}"
      else
        endpoints[endpoint] = label
      end
    end
  end
end

if errors.empty?
  puts "Validation passed"
else
  warn "Validation failed:"
  errors.each { |error| warn "- #{error}" }
  exit 1
end
