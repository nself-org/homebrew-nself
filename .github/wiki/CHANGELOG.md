# Changelog

All notable changes to the homebrew-nself tap are documented here.

The tap tracks nSelf CLI releases. Each entry corresponds to a CLI version bump in `Formula/nself.rb`.

---

## [1.1.0] - 2026-05-15

### Changed

- **Formula version bump** (S13.T23): `Formula/nself.rb` `version` field bumped to `1.1.0`; `url` updated to `https://github.com/nself-org/cli/archive/refs/tags/v1.1.0.tar.gz`.
- **Tarball SHA256** (S13.T23): updated to `26100f068ee6d96fa46fa0026052f67242c3675c4b057814a350ac917ee576d2`.
- **Minimum macOS version**: 12 (Monterey) for Homebrew formula.
- `brew upgrade nself` installs v1.1.0; downstream effect: every consumer of nSelf CLI (admin, web/backend, nchat/.backend, nclaw/.backend, ntv/.backend, ntask/.backend) picks up bundle/feature/backup/man/costs/migrate commands.

### Notes

- Auto-updated by GitHub Actions release workflow on CLI v1.1.0 tag publish; SHA placeholder above will be replaced inline.
- No formula logic changes — pure version + SHA bump.
- See [nSelf CLI CHANGELOG](https://github.com/nself-org/cli/wiki/CHANGELOG) for CLI-level changes (bundle/feature/backup/man/costs/migrate commands, 5 new doctor checks, idempotent trust install).

---

## v1.0.16 — 2026-05-05

Formula updated to CLI v1.0.16 SHAs.

---

## v1.0.9 — 2026-04-17

Initial Go-rewrite baseline. Formula re-written for Go binary distribution (was Bash script).
