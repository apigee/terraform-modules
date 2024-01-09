# Changelog

## [0.19.1](https://github.com/apigee/terraform-modules/compare/v0.19.0...v0.19.1) (2024-01-09)


### Bug Fixes

* Correct docs check and update samples to include new type argument ([2b9e95d](https://github.com/apigee/terraform-modules/commit/2b9e95df16d0f862e3684d303920efdc08abd953))

## [0.19.0](https://github.com/apigee/terraform-modules/compare/v0.18.1...v0.19.0) (2023-12-19)


### Features

* Bump module dependencies to latest Cloud Foundation Fabric v28.0.0 ([d34508d](https://github.com/apigee/terraform-modules/commit/d34508dd64b829ac5061c7ab53fb8fb767698d47))

## [0.18.1](https://github.com/apigee/terraform-modules/compare/v0.18.0...v0.18.1) (2023-11-22)


### Bug Fixes

* Fix bug in apigee-x-core output, not returning the documented map of instance name to instance endpoint IP ([23ae4b7](https://github.com/apigee/terraform-modules/commit/23ae4b7acc753697fe1559446967eafa19c66541))
* Fix locals definition to correctly pass the instance name from variables to the apigee module ([5343c12](https://github.com/apigee/terraform-modules/commit/5343c1226e7f7a0075fe307bbe2c4d3311191f89))

## [0.18.0](https://github.com/apigee/terraform-modules/compare/v0.17.0...v0.18.0) (2023-09-26)


### Features

* bumped cff module version for apigee & kms to v26.0.0 ([5a0d4a3](https://github.com/apigee/terraform-modules/commit/5a0d4a3294bf8392d440f93a19330389e1dc54ed))

## [0.17.0](https://github.com/apigee/terraform-modules/compare/v0.16.0...v0.17.0) (2023-06-28)


### Features

* allow consumer_accept_list in apigee-x-core module ([#129](https://github.com/apigee/terraform-modules/issues/129)) ([0fea0a7](https://github.com/apigee/terraform-modules/commit/0fea0a7fc1f564198c622ea9829eef995014d043))

## [0.16.0](https://github.com/apigee/terraform-modules/compare/v0.15.1...v0.16.0) (2023-06-15)


### Features

* configurable keyrings creation in Apigee X core module ([d70b66d](https://github.com/apigee/terraform-modules/commit/d70b66dc0948775646b1f5fd5e4f7ebbf9703ac3))

## [0.15.1](https://github.com/apigee/terraform-modules/compare/v0.15.0...v0.15.1) (2023-06-14)


### Bug Fixes

* **modules/sb-psc-attachment:** remove explicit organizations prefix on variable ([e4b460f](https://github.com/apigee/terraform-modules/commit/e4b460f48b9877b90bc2169e271e9f0d03af7f80))

## [0.15.0](https://github.com/apigee/terraform-modules/compare/v0.14.1...v0.15.0) (2023-04-23)


### Features

* add l7ilb psc neg ingress module and samples ([74296cc](https://github.com/apigee/terraform-modules/commit/74296cc6d57fb8e56be5a2684beecf3dbbb31492))

## [0.14.1](https://github.com/apigee/terraform-modules/compare/v0.14.0...v0.14.1) (2023-04-12)


### Bug Fixes

* ssl_certificates usage for https target proxy ([df17c2c](https://github.com/apigee/terraform-modules/commit/df17c2c398bc0bb78d66607b51ba971b701099c3))

### Build Changes

* disable python ruff linter ([f3f298f](https://github.com/apigee/terraform-modules/commit/f3f298f04cad5c2be5eb01c398f8873d0ae9a041))

## [0.14.0](https://github.com/apigee/terraform-modules/compare/v0.13.0...v0.14.0) (2023-03-26)


### Features

* adding logs and timeout parameters to external load balancer ([a444206](https://github.com/apigee/terraform-modules/commit/a444206cc7764f507906442ba1250deab51d18c1))
* adding ssl policy capability ([f11131e](https://github.com/apigee/terraform-modules/commit/f11131e1870234271ae98a05c1ae0fc8f14b6928))


### Bug Fixes

* apigee envgroups usage for apigee module ([82b3364](https://github.com/apigee/terraform-modules/commit/82b3364d96e8037826e29eee9eb3884ba92641d7))
* hybrid gke sample with envgroups and outputs ([35d24e9](https://github.com/apigee/terraform-modules/commit/35d24e9fea295eab199e8cbf52e189cb7ff91cf0))
* interpolation only expr in hybrid gke samples ([0197c04](https://github.com/apigee/terraform-modules/commit/0197c04e210294091621404a789cb08b7f730bd8))
* nb psc xlb sample for network usage ([7fa327d](https://github.com/apigee/terraform-modules/commit/7fa327d3b411b3761a46e2c65f78f93ed8525347))
* remove unused tf vars from hybrid gke samples ([f0dd715](https://github.com/apigee/terraform-modules/commit/f0dd715225e4560e888c15585aa44116cde9eaf9))
* sample for nb psc xlb usage ([0f4d7df](https://github.com/apigee/terraform-modules/commit/0f4d7dfb49d10fc4e5c944e898ffd04bde9686a0))
* sb psc attach module endpoint attachment ([8040775](https://github.com/apigee/terraform-modules/commit/8040775771357ad6bb99fecd1d6927de60b9af25))
* unused psc network conf for nbpscl7xlb module ([56ac556](https://github.com/apigee/terraform-modules/commit/56ac556dd6869bc70a880aa97b318820d24f5bc0))
* unused tf refs in nbpscl7xlb module ([2ae0e9e](https://github.com/apigee/terraform-modules/commit/2ae0e9e3e66c8fe5182bae43424515b7e770d80d))

## [0.13.0](https://github.com/apigee/terraform-modules/compare/v0.12.0...v0.13.0) (2023-01-26)


### Features

* :sparkles: add labels to forwarding rule resources ([dc58039](https://github.com/apigee/terraform-modules/commit/dc58039c6210c072c77c2eb0e0ce10f6a1befde8))
* bump Mega Linter version to v6 in GitHub Actions [d3bdcc9](https://github.com/apigee/terraform-modules/commit/d3bdcc9ecb8fc2b8340abed61a3079ec9720e5ab)
* use v19.0.0 of Cloud Foundation Fabric Apigee module ([8a1a6dd](https://github.com/apigee/terraform-modules/commit/17d7abbf0e0794eb3b6fc85fb87e7bf73e72372d))


## [0.12.0](https://github.com/apigee/terraform-modules/compare/v0.11.0...v0.12.0) (2022-11-11)


### Features

* cloud build for hybrid resources ([0109373](https://github.com/apigee/terraform-modules/commit/0109373ca3964ba74d7d57b7f1ef923b931c5826))


### Bug Fixes

* remove cloud build default substitution values ([d61f5a7](https://github.com/apigee/terraform-modules/commit/d61f5a795cff1299451ba0a8a788845252b18f91))

## [0.11.0](https://github.com/apigee/terraform-modules/compare/v0.10.0...v0.11.0) (2022-11-03)


### Features

* bump mig image from debian 10 to debian 11 ([323f49c](https://github.com/apigee/terraform-modules/commit/323f49c2b0c36edabfeef51cfe6d7af376626fd9))

## [0.10.0](https://github.com/apigee/terraform-modules/compare/v0.9.0...v0.10.0) (2022-10-31)


### Features

* adding PSC NB support for custom VPCs and PSC NEGs in multiple regions ([b2fbd7f](https://github.com/apigee/terraform-modules/commit/b2fbd7f5f452a363ac8e01b6ea5aef534db1b5a3))


### Bug Fixes

* reference breaking hyperlink ([85cb9d7](https://github.com/apigee/terraform-modules/commit/85cb9d7d7d9a9361756bd320c13e84aee2862b3c))

## [0.9.0](https://github.com/apigee/terraform-modules/compare/v0.8.0...v0.9.0) (2022-10-21)


### Features

* Preview of Apigee hybrid on GKE sample ([fffeb15](https://github.com/apigee/terraform-modules/commit/fffeb15d7661e7fc8e33ebbdc0818f76098b5063))

## [0.8.0](https://github.com/apigee/terraform-modules/compare/v0.7.0...v0.8.0) (2022-10-13)


### Features

* add Apigee X org outputs ([c4c3bf8](https://github.com/apigee/terraform-modules/commit/c4c3bf84f2ff982840f11501ca204b9edbcb71c3))
* allow for autoscale and target size variables ([05eeee8](https://github.com/apigee/terraform-modules/commit/05eeee8d7a327b635ed3cdeaf80e77d33b473719))

## [0.7.0](https://github.com/apigee/terraform-modules/compare/v0.6.0...v0.7.0) (2022-10-03)


### Features

* improve mTLS documentation and dependencies ([da2bfa4](https://github.com/apigee/terraform-modules/commit/da2bfa48b6ca34c3b4e91208c39c05fd62a40f57))

## [0.6.0](https://github.com/apigee/terraform-modules/compare/v0.5.1...v0.6.0) (2022-09-28)


### Features

* **psc-sb:** add connection_state output for endpoint attachment ([5fc3edc](https://github.com/apigee/terraform-modules/commit/5fc3edc2e6831abce0a1888e8f77dbfb0c20c58d))

## [0.5.1](https://github.com/apigee/terraform-modules/compare/v0.5.0...v0.5.1) (2022-09-22)


### Bug Fixes

* expose instance object on Apigee core module ([b81e9e6](https://github.com/apigee/terraform-modules/commit/b81e9e60598769c9de610a8e795f6b1ca1dde01e))

## [0.5.0](https://github.com/apigee/terraform-modules/compare/v0.4.0...v0.5.0) (2022-09-12)


### Features

* add security_policy to l7xlb module ([686e549](https://github.com/apigee/terraform-modules/commit/686e5498ec42c4315f2812de3da3dcd38f8c5bd9))

## [0.4.0](https://github.com/apigee/terraform-modules/compare/v0.3.0...v0.4.0) (2022-08-19)


### Features

* configurable network and subnet for PSC NEG ([9e75b21](https://github.com/apigee/terraform-modules/commit/9e75b210406e7b901afe4219803d0f45b9bbec8c))


### Bug Fixes

* remove issue reference from PSC NEG readme ([027277d](https://github.com/apigee/terraform-modules/commit/027277df65a0db6c716571a90d77675f1f6646a1))

## [0.3.0](https://github.com/apigee/terraform-modules/compare/v0.2.2...v0.3.0) (2022-08-11)


### Features

* add org kms key ring custom name logic ([0a29fc0](https://github.com/apigee/terraform-modules/commit/0a29fc006f49012cd078319f39fda6ec54a1371e))

## [0.2.2](https://github.com/apigee/terraform-modules/compare/v0.2.1...v0.2.2) (2022-08-10)


### Bug Fixes

* add typed config to envoy sample ([61dd701](https://github.com/apigee/terraform-modules/commit/61dd7018fb94675ebe1124cc1136a266fc2d1ea5))

## [0.2.1](https://github.com/apigee/terraform-modules/compare/v0.2.0...v0.2.1) (2022-08-04)


### Bug Fixes

* code structure cleanup ([12075d0](https://github.com/apigee/terraform-modules/commit/12075d0f8706ed15cee742c7eef58eb56760f0c6))

## [0.2.0](https://github.com/apigee/terraform-modules/compare/v0.1.0...v0.2.0) (2022-08-02)


### Features

* add default KMS rotation for KMS keys used in apigee core ([61fe6c8](https://github.com/apigee/terraform-modules/commit/61fe6c8a11cc8a926608096e9b8651dc3616b12f))

## 0.1.0 (2022-07-18)


### Features

* :sparkles: Implemented release versioning ([5960b43](https://github.com/apigee/terraform-modules/commit/5960b43908407603eee29e1d85141d14d102f6c4))
