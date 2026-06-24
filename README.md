# eplist

[![Contributors](https://img.shields.io/github/contributors/eplist/eplist.svg)](https://github.com/badges/eplist/eplist/contributors)
[![visits](https://visitor.vercel.app/page/eplist-eplist?color=light-green)](https://github.com/eplist/eplist)
[![License](https://img.shields.io/github/license/eplist/eplist.svg)](https://github.com/eplist/eplist/blob/master/LICENSE)

## Introduction

云存储各大厂商都没有提供endpoint的列表API，所以我们通过开源社区的方式维护一份。

利用它，可以在配置云存储时快速选择需要的endpoint。

## Platforms
- [Akamai Object Storage](akamai.yml)
- [阿里云OSS](oss.yml)
- [腾讯云COS](cos.yml)
- [DigitalOcean Spaces](digitalocean-spaces.yml)
- [DreamObjects](dreamobjects.yml)
- [Exoscale SOS](exoscale.yml)
- [Gcore Object Storage](gcore.yml)
- [Google Cloud Storage](google-cloud-storage.yml)
- [Hetzner Object Storage](hetzner.yml)
- [IBM Cloud Object Storage](ibm-cos.yml)
- [IONOS Object Storage](ionos.yml)
- [OVHcloud Object Storage](ovhcloud.yml)
- [Scaleway Object Storage](scaleway.yml)
- [Storj](storj.yml)
- [Tigris](tigris.yml)
- [七牛Kodo](kodo.yml)
- [网易云NOS](nos.yml)
- [华为云OBS](obs.yml)
- [亚马云S3](s3.yml)
- [优刻得US3](us3.yml)
- [Vultr Object Storage](vultr.yml)
- [Wasabi](wasabi.yml)
- [Yandex Object Storage](yandex.yml)

## Usage


### curl
```bash
curl https://raw.githubusercontent.com/eplist/eplist/main/oss.yml
```

### Js-axios
```js
import axios from "axios";
import yamlLoader from "js-yaml";

axios.get(`https://raw.githubusercontent.com/eplist/eplist/main/oss.yml`).then((data) => {
  let eplist = yamlLoader.load(data);
  console.log(eplist.endpoints);
})
```


## License
This repo is under the MIT license. See the [LICENSE](/LICENSE) file for details.
