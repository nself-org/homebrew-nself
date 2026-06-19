# Formula auto-updated by goreleaser on each CLI release.
# Dual-arch sha256 blocks use the pre-built darwin binaries published to GitHub
# Releases (nself-<ver>-darwin-{arm64,amd64}.tar.gz). The sha256 values are
# taken from the release's checksums.txt and must be kept in sync with the tag.
class Nself < Formula
  desc "Self-hosted backend infrastructure CLI: Postgres, GraphQL, Auth, Nginx in 5 minutes"
  homepage "https://nself.org"
  version "1.1.9"
  license "MIT"

  on_arm do
    url "https://github.com/nself-org/cli/releases/download/v#{version}/nself-#{version}-darwin-arm64.tar.gz"
    sha256 "f66b565bc055ff8246c26d0337d9ed2c651e55d3917dae89957c91e686250021"
  end

  on_intel do
    url "https://github.com/nself-org/cli/releases/download/v#{version}/nself-#{version}-darwin-amd64.tar.gz"
    sha256 "c87572b7c2533c8d5b2c5253858e2c65942f7ae75e9068b6bcc86f56be93700b"
  end

  depends_on "docker"
  depends_on "docker-compose"

  def install
    bin.install "nself"
  end

  test do
    system "#{bin}/nself", "version"
    system "#{bin}/nself", "help"
    system "#{bin}/nself", "doctor", "--help"
  end
end
