# Contributing to homebrew-nself

## What This Is

The Homebrew tap for nSelf CLI. The formula auto-syncs when a new GitHub release is published.

## Prerequisites

- macOS with Homebrew
- Ruby 3.0+ (for formula development)

## Testing

```bash
brew audit --strict Formula/nself.rb
brew install --build-from-source Formula/nself.rb
brew test Formula/nself.rb
```

## Pull Requests

The formula auto-updates from GitHub releases. Manual edits should only fix bugs in the formula itself, not bump versions.

1. Fork and create a branch
2. `brew audit --strict` must pass
3. Submit PR against `main`

## Commit Style

Conventional commits: `chore:`, `fix:`
