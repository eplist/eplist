#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)

def badge_payload(label, message)
  {
    "schemaVersion" => 1,
    "label" => label,
    "message" => message.to_s,
    "color" => "blue"
  }
end

Dir.chdir(ROOT) do
  index = YAML.load_file("index.yml")
  provider_count = index.fetch("providers").size
  endpoint_count = (Dir["*.yml"].sort - ["index.yml"]).sum do |file|
    YAML.load_file(file).fetch("endpoints").size
  end

  FileUtils.mkdir_p("badges")
  File.write("badges/providers.json", "#{JSON.pretty_generate(badge_payload("providers", provider_count))}\n")
  File.write("badges/endpoints.json", "#{JSON.pretty_generate(badge_payload("endpoints", endpoint_count))}\n")

  puts "providers=#{provider_count}"
  puts "endpoints=#{endpoint_count}"
end
