class Nself < Formula
  desc "ɳSelf v1.0.4: ɳClaw production-ready, knowledge graph, agent dashboard, image gen"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "c915d8337f12836a571ca2feb6c13c004a3764bffc69631916ae8c8d993ea944"
  license "Source-Available"
  version "1.0.4"

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