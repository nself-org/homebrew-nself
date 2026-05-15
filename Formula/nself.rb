class Nself < Formula
  desc "Self-hosted backend infrastructure CLI: Postgres, GraphQL, Auth, Nginx in 5 minutes"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/releases/download/v1.1.2/nself-cli-1.1.2.tar.gz"
  # sha256 from the IMMUTABLE release-asset tarball uploaded via `gh release upload`
  # (auto-generated /archive/refs/tags/*.tar.gz is unstable across GitHub CDN regions)
  # TODO: sha256 placeholder — update after CLI v1.1.2 tag is pushed and tarball is available at GitHub
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  version "1.1.2"

  depends_on "go" => :build
  depends_on "docker"
  depends_on "docker-compose"

  def install
    ldflags = %W[
      -s -w
      -X github.com/nself-org/cli/internal/version.Version=#{version}
    ]

    system "go", "build", "-mod=vendor", "-ldflags", ldflags.join(" "),
           "-o", bin/"nself", "./cmd/nself/"

    doc.install "LICENSE" if File.exist?("LICENSE")
  end

  test do
    system "#{bin}/nself", "version"
    system "#{bin}/nself", "help"
    system "#{bin}/nself", "doctor", "--help"
  end
end