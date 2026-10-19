# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added

- Initial `terraform-volcenginecc-eip` module.
- Stable map-based independent EIP allocation with billing, bandwidth, ISP, project, naming, and tags.
- Optional Provider-supported ECS, NAT Gateway, network-interface, CLB, and HaVip binding inputs.
- Basic and complete examples and static validation.
- Read-only reuse of explicitly identified existing EIPs with ownership-aware outputs.

### Changed

- Require an explicit `release_with_instance` decision for pay-as-you-go ECS bindings and document that it is not general deletion protection.
