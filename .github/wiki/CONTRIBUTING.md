# Contributing to homebrew-nself

This is the official Homebrew tap for the nSelf CLI.

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

## Code Style

- Ruby formula follows standard Homebrew conventions
- Keep the formula minimal and focused
- Dependencies: `docker` and `docker-compose` (required by nSelf CLI)

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Update the formula (usually `url`, `sha256`, `version`)
4. Run `ruby -c Formula/nself.rb` to verify syntax
5. Test with `brew install --build-from-source`
6. Submit a PR

## Version Updates

Formula version bumps are automated via GitHub Actions when a new CLI release is published. Manual updates follow the same PR process.

## Reporting Issues

Open an issue on GitHub with:
- macOS version
- Homebrew version (`brew --version`)
- Full error output
