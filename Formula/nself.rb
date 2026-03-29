class Nself < Formula
  desc "ɳSelf v1.0.1: Production Ready - Complete self-hosted backend infrastructure for v1.0 LTS"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "b712a6398e27769cf6af7b2ecbd6f234c81601c8bfb631c52519e7762ba0b34a"
  license "Source-Available"
  version "1.0.1"

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
  end
end