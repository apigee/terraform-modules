# Changelog

## [0.9.0](https://github.com/apigee/terraform-modules/compare/v0.8.0...v0.9.0) (2022-10-21)


### Features

* add instructions for installing hybrid ([16cf357](https://github.com/apigee/terraform-modules/commit/16cf357a11c4e74423e62cc4ff3848f711b89655))
* better yaml splitting for sealed secrets in hybrid demo ([9e17cc3](https://github.com/apigee/terraform-modules/commit/9e17cc3eadaa45977eadaf1d843733d59f22490f))
* configurable machine type for hybrid cluster ([f02db36](https://github.com/apigee/terraform-modules/commit/f02db36ae86a2bfd1b8d442bcc06e5867b360949))
* hybrid example with reduced infra costs ([cedd1ff](https://github.com/apigee/terraform-modules/commit/cedd1ff9af41bd2fb95141d60040da3bf255a3ba))
* **hybrid-basic:** deploy sealed secrets as helm chart ([b88ab1c](https://github.com/apigee/terraform-modules/commit/b88ab1c169d47e0d946ba8ba4507e1834dc1719b))
* move cert manager to helm chart ([2aff39d](https://github.com/apigee/terraform-modules/commit/2aff39d0b8b728d2fd64733c187725c48a76be37))
* replace csplit with awk for better multi-platform support ([a9b636b](https://github.com/apigee/terraform-modules/commit/a9b636b1dccbef2fc6ac8e63d02f9bc2efc57804))

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
