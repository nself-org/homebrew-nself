class Nself < Formula
  desc "Self-hosted backend infrastructure CLI — spin up Postgres, Hasura, Auth, and Nginx in minutes"
  homepage "https://nself.org"
  url "https://github.com/nself-org/cli/archive/refs/tags/v0.9.9.tar.gz"
  # sha256 verified against v0.9.9 release tarball at time of release
  sha256 "793ae62e6a5a778fc19c63b48c71e33833b2d98df1d8e2a35b5af87f597320d5"
  license "MIT"
  version "0.9.9"

  depends_on "bash" => :recommended  # Requires Bash 3.2+
  depends_on "docker" => :recommended
  # docker-compose is now a Docker CLI plugin in Docker Desktop v2+.
  # Keep as optional dependency for standalone docker-compose installations.
  depends_on "docker-compose" => :optional

  def install
    # Install ONLY essential source directories to libexec (exclude tests, examples)
    libexec.mkpath

    # Copy VERSION file
    (libexec/"src").install "src/VERSION" if File.exist?("src/VERSION")

    # Install only essential directories (exclude tests, examples, development files)
    %w[cli lib templates services].each do |dir|
      (libexec/"src").install "src/#{dir}" if File.directory?("src/#{dir}")
    end

    # Create the main executable wrapper
    (bin/"nself").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/src/cli/nself.sh" "$@"
    EOS

    # Make it executable
    (bin/"nself").chmod 0755

    # Install minimal documentation (LICENSE only, docs available online)
    doc.install "LICENSE" if File.exist?("LICENSE")
  end

  def post_install
    # Create .nself directory structure
    nself_dir = File.expand_path("~/.nself")
    FileUtils.mkdir_p(nself_dir)

    # Copy source and templates to ~/.nself
    FileUtils.cp_r("#{libexec}/src", nself_dir)
    FileUtils.cp_r("#{libexec}/templates", nself_dir) if File.exist?("#{libexec}/templates")

    # NOTE: ~/.nself contains user configuration and is NOT removed on uninstall.
    # Users should manually remove ~/.nself if they want a clean uninstall.

    ohai "ɳSelf has been installed successfully!"
    ohai "Run 'nself init' to get started with your first ɳSelf project"
  end

  def caveats
    <<~EOS
      ɳSelf has been installed to #{bin}/nself

      Get started:
        nself init
        nself start

      Documentation: https://docs.nself.org

      Note: Your configuration is stored in ~/.nself
      It is preserved when you uninstall nself. To fully remove:
        rm -rf ~/.nself
    EOS
  end

  test do
    # Verify binary runs and returns valid output
    version_output = shell_output("#{bin}/nself version 2>&1")
    assert_match "nself", version_output.downcase

    # Verify help works
    help_output = shell_output("#{bin}/nself help 2>&1", 0)
    assert_match "Usage:", help_output

    # Verify init directory was created
    assert_predicate File.join(Dir.home, ".nself"), :exist?
  end
end
