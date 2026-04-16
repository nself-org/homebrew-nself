class Nself < Formula
  desc "ɳSelf v1.0.7: P92 Wave 7 patch — billing subcommand fix, JWT auto-persist, doctor tests"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.7.tar.gz"
  sha256 "6a903853b617fe8fd5eadf5ae6ecc2f0136a351342708ed669eb1a25f098eafa"
  license "Source-Available"
  version "1.0.7"

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