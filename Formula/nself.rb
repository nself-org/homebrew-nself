# Formula auto-updated on each CLI release.
# Dual-arch sha256 blocks use the pre-built darwin binaries published to GitHub
# Releases (nself-<ver>-darwin-{arm64,amd64}.tar.gz). The sha256 values are
# taken from the release's checksums.txt and must be kept in sync with the tag.
class Nself < Formula
  desc "Self-hosted backend CLI: Postgres, GraphQL, Auth, Nginx in minutes"
  homepage "https://nself.org"
  version "1.4.11"
  license "MIT"

  depends_on "docker"
  depends_on "docker-compose"

  on_macos do
    on_arm do
      url "https://github.com/nself-org/cli/releases/download/v#{version}/nself-#{version}-darwin-arm64.tar.gz"
      sha256 "6164b25eec96a5fa2468f3061a142a18de74fb234f6ee8937b9093d4d539ac1b"
    end

    on_intel do
      url "https://github.com/nself-org/cli/releases/download/v#{version}/nself-#{version}-darwin-amd64.tar.gz"
      sha256 "b565227e0753844d7cf891925e114db2aac8a198021dde3845fc1d286dbf18f7"
    end
  end

  # Install the nself binary into the bin directory.
  # Purpose: Extract and place the pre-built CLI binary into the standard Homebrew installation path.
  # Inputs: bin (Homebrew-provided bin installation directory)
  # Outputs: nself binary available in PATH
  # Constraints: The tarball must contain a top-level 'nself' executable; if not, installation fails.
  def install
    bin.install "nself"
  end

  # Run post-install verification tests for the nself binary.
  # Purpose: Verify that the installed binary is executable and responds to basic commands.
  # Inputs: bin/nself from install phase
  # Outputs: Exit 0 if all tests pass; non-zero if any test fails
  # Constraints: docker and docker-compose dependencies must be available on the system.
  #              Tests do not verify docker functionality, only nself CLI responsiveness.
  test do
    system "#{bin}/nself", "version"
    system "#{bin}/nself", "help"
    system "#{bin}/nself", "doctor", "--help"
  end
end
