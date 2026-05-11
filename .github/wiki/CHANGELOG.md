# Changelog

All notable changes to the homebrew-nself tap are documented here.

The tap tracks nSelf CLI releases. Each entry corresponds to a CLI version bump in `Formula/nself.rb`.

---

## v1.1.0 — PENDING (v1.1.0 ecosystem release)

### Changed

- Formula updated to CLI v1.1.0 tarball SHAs (darwin/linux × amd64/arm64).
- Minimum macOS version: 12 (Monterey) for Homebrew formula.
- `brew upgrade nself` installs v1.1.0.

### Notes

- Auto-updated by GitHub Actions release workflow on CLI v1.1.0 tag publish.
- No formula logic changes — pure version and SHA bump.
- See [nSelf CLI CHANGELOG](https://github.com/nself-org/cli/wiki/CHANGELOG) for CLI-level changes.

---

## v1.0.16 — 2026-05-05

Formula updated to CLI v1.0.16 SHAs.

---

## v1.0.9 — 2026-04-17

Initial Go-rewrite baseline. Formula re-written for Go binary distribution (was Bash script).
