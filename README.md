# SourceOS Homebrew Tap

This repository is the SourceOS distribution surface for Homebrew formulas/casks. It is not a runtime governance authority.

## Formulas

Current SourceOS product-surface formulas include:

- `agent-machine`
- `bearbrowser`
- `noetica`
- `sourceos-devtools`
- `sourceos-syncd`
- `turtleterm`

## Noetica service boundary

The Noetica formula installs the workstation CLI and exposes `noetica`.

Homebrew is not the canonical service supervisor for Noetica. Use Noetica's OS-native service adapter commands instead:

```bash
noetica service install
noetica service start
noetica service status
noetica service stop
noetica service uninstall
```

Noetica service mode uses `launchctl` / LaunchAgent on macOS and `systemd --user` or a SourceOS-compatible user service on Linux.

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
