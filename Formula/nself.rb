class Nself < Formula
  desc "ɳSelf v1.0.2: Critical local dev fixes, nself trust, migration fix"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "86d870a366b2286f06dc457863e69a5b04786cee001bdb2692164fbea93b7954"
  license "Source-Available"
  version "1.0.2"

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