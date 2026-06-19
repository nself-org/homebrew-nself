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
    sha256 "c0c482209beb487d5b6062433b8966b3972a18de6d8125274eea404d8d687d50"
  end

  on_intel do
    url "https://github.com/nself-org/cli/releases/download/v#{version}/nself-#{version}-darwin-amd64.tar.gz"
    sha256 "221f6133d42541275d926238235ec8e16990e99f13c3c75d9353cfda9a92f89e"
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
