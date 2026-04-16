class Nself < Formula
  desc "ɳSelf v1.0.6: P89/P90 + P92 coordinated release — goreleaser, compliance checker, pro plugin hardening"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.6.tar.gz"
  sha256 "3f2e43d41a17dab3a6e785623a9b357ecaca99d892f0f20235ccb4905c392f10"
  license "Source-Available"
  version "1.0.6"

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