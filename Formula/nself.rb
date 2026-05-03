class Nself < Formula
  desc "Self-hosted backend infrastructure CLI: Postgres, GraphQL, Auth, Nginx in 5 minutes"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.15.tar.gz"
  # sha256 computed from https://github.com/nself-org/cli/archive/refs/tags/v1.0.15.tar.gz
  sha256 "7ca87c894a7d6ba72636ae47fb4851aa2f5d0dd0abbe870c366364e322750157"
  license "MIT"
  version "1.0.15"

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