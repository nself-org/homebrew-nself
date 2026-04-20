# Contributing to homebrew-nself

## What This Is

The official Homebrew tap for the nSelf CLI. The formula auto-syncs when a new GitHub release is published.

## Prerequisites

- macOS with Homebrew
- Ruby 3.0+ (for formula development)

## Development Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/nself-org/homebrew-nself.git
   ```

2. Install Homebrew if you don't have it:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. Test the formula locally:
   ```bash
   brew install --build-from-source Formula/nself.rb
   ```

4. Audit the formula:
   ```bash
   brew audit --strict Formula/nself.rb
   ```

5. Run the formula's test block:
   ```bash
   brew test Formula/nself.rb
   ```

## Code Style

- Ruby formula follows standard Homebrew conventions.
- Keep the formula minimal and focused.
- Dependencies: `docker` and `docker-compose` are required by the nSelf CLI and must always be present in the formula.
- The `post_install` block copies source files to `~/.nself/`. Do not remove or rename this step.
- The `test` block must verify `nself version` and `nself help` succeed. Do not weaken the test block.

## Formula Structure

A minimal formula update looks like this:

```ruby
class Nself < Formula
  desc "Self-hosted backend infrastructure platform — v1.0.9"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.9.tar.gz"
  sha256 "YOUR_SHA256_HERE"
  version "1.0.9"
  license "MIT"

  depends_on "docker" => :recommended
  depends_on "docker-compose" => :recommended

  def install
    # install steps
  end

  def post_install
    # copy to ~/.nself/
  end

  test do
    system "#{bin}/nself", "version"
    system "#{bin}/nself", "help"
  end
end
```

## Computing SHA256

When computing the SHA256 for a new release:

```bash
# Download the tarball
curl -L https://github.com/nself-org/cli/archive/refs/tags/v1.0.9.tar.gz -o nself-v1.0.9.tar.gz

# Compute SHA256
shasum -a 256 nself-v1.0.9.tar.gz
```

Paste the output hash into the formula's `sha256` field.

## Version Update Checklist

When updating for a new CLI release:

1. Update `url` to the new release tag
2. Update `sha256` with the computed hash
3. Update `version`
4. Update `desc` version number if it appears there
5. Run `brew audit --strict Formula/nself.rb`
6. Run `brew install --build-from-source Formula/nself.rb`
7. Run `brew test Formula/nself.rb`
8. Commit: `chore: bump nself formula to v1.0.x`

## Pull Request Process

The formula auto-updates from GitHub releases. Manual edits should only fix bugs in the formula itself, not bump versions.

1. Fork the repository
2. Create a feature branch
3. Update the formula (usually `url`, `sha256`, `version`)
4. Run `ruby -c Formula/nself.rb` to verify syntax
5. `brew audit --strict` must pass
6. Test with `brew install --build-from-source`
7. Submit a PR against `main`

## Commit Style

Conventional commits: `chore:`, `fix:`

## Version Updates

Formula version bumps are automated via GitHub Actions when a new CLI release is published. Manual updates follow the same PR process.

## Reporting Issues

Open an issue on GitHub with:
- macOS version
- Homebrew version (`brew --version`)
- Full error output

## Security Disclosures

Do not open a public issue for security vulnerabilities. Follow the process in [SECURITY.md](https://github.com/nself-org/homebrew-nself/blob/main/.github/SECURITY.md).

## Governance

This tap follows the nSelf [BDFL governance model](https://github.com/nself-org/homebrew-nself/blob/main/.github/GOVERNANCE.md). Formula changes are reviewed by the founder. See [CODEOWNERS](https://github.com/nself-org/homebrew-nself/blob/main/.github/CODEOWNERS).

Formula version bumps are owned by the release automation — do not submit bump-only PRs unless automation is broken.

## Code of Conduct

All contributors are expected to follow the [Code of Conduct](Code-of-Conduct.md). Enforcement process is described in [ENFORCEMENT.md](https://github.com/nself-org/homebrew-nself/blob/main/.github/ENFORCEMENT.md).

## Questions

- [GitHub Discussions](https://github.com/nself-org/homebrew-nself/discussions) — for questions about the tap or formula
- [nself-org/cli Discussions](https://github.com/nself-org/cli/discussions) — for questions about the CLI itself
- Community: [nself.org](https://nself.org)

## Related

- [GOVERNANCE.md](https://github.com/nself-org/homebrew-nself/blob/main/.github/GOVERNANCE.md) — decision model
- [ENFORCEMENT.md](https://github.com/nself-org/homebrew-nself/blob/main/.github/ENFORCEMENT.md) — code of conduct enforcement
- [CODEOWNERS](https://github.com/nself-org/homebrew-nself/blob/main/.github/CODEOWNERS) — who reviews what
- [nSelf CLI repo](https://github.com/nself-org/cli) — the CLI this formula installs
- [[Home]] — tap overview

## Branching Model

| Branch | Purpose |
|---|---|
| `main` | Current stable formula |
| `fix/xxx` | Bug fixes in formula |
| `chore/xxx` | Maintenance updates |

All PRs target `main`. Automated bump PRs are opened by the release workflow.

---
← [[Home]] | [[_Sidebar]]
