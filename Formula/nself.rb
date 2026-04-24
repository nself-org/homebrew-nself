class Nself < Formula
  desc "Self-hosted backend infrastructure CLI: Postgres, GraphQL, Auth, Nginx in 5 minutes"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v1.0.11.tar.gz"
  # sha256 computed from https://github.com/nself-org/cli/archive/refs/tags/v1.0.11.tar.gz
  sha256 "9f3edce0d6ed9138c87f3477138071aca595caf3c49746e67eb880ded7f9ca4d"
  license "MIT"
  version "1.0.11"

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

  def post_install
    # Run the onboarding funnel check after a fresh Homebrew install.
    # Runs in the background so `brew install` completes immediately.
    # Output is suppressed; any funnel telemetry fires asynchronously.
    # Safe to run repeatedly — checks are read-only and idempotent.
    ohai "Running nself onboarding check..."
    system "#{bin}/nself", "doctor", "--install-check"
  rescue StandardError
    # Never block a successful install due to a doctor check failure.
    opoo "nself doctor --install-check encountered an error (non-fatal)."
  end

  test do
    system "#{bin}/nself", "version"
    system "#{bin}/nself", "help"
    system "#{bin}/nself", "doctor", "--install-check", "--json"
  end
end