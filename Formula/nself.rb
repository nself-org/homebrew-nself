class Nself < Formula
  desc "ɳSelf v1.0.3: Security hardening, 87 plugins, nself security command"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "e8bf5ce2fa6201a281fa60a4dcf3904237c5b79e379412d8f13bfa81006562c0"
  license "Source-Available"
  version "1.0.3"

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