# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added

- Initial `terraform-volcenginecc-eip` module.
- Stable map-based independent EIP allocation with billing, bandwidth, ISP, project, naming, and tags.
- Optional Provider-supported ECS, NAT Gateway, network-interface, CLB, and HaVip binding inputs.
- Basic and complete examples, static validation, and retained real-cloud lifecycle fixtures.
- Read-only reuse of explicitly identified existing EIPs with ownership-aware outputs.
- Executable ECS/NAT binding, external-EIP/NLB composition, and binding-migration acceptance assets.

### Changed

- Require an explicit `release_with_instance` decision for pay-as-you-go ECS bindings and document that it is not general deletion protection.
