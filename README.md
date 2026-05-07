# SourceOS Homebrew Tap

This repository is the SourceOS distribution surface for Homebrew formulas/casks. It is not a runtime governance authority.

## Release evidence mapping

Release/package operations and evidence for product surfaces are tracked in:

- `release-evidence/workspace-operations.json`

The evidence map includes:

- operation types:
  - `release.package.prepare`
  - `release.formula.update`
  - `release.checksum.verify`
  - `release.evidence.attach`
  - `release.rollback.record`
- required release artifacts/evidence:
  - package formula
  - checksum record
  - release note
  - rollback note
  - build/test evidence link
  - source commit reference
  - artifact provenance record

## Governance boundary

Hard rule: packaging is distribution, not runtime governance. Releases carried by this tap must map back to source repositories where contracts, tests, and policy gates are enforced.
