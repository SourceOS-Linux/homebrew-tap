class Noetica < Formula
  desc "SocioProphet / SourceOS governed Noetica workstation UI"
  homepage "https://github.com/SocioProphet/Noetica"
  url "https://github.com/SocioProphet/Noetica.git", branch: "main"
  version "0.1.0-dev"
  license "MIT"
  head "https://github.com/SocioProphet/Noetica.git", branch: "main"

  RELEASE_EVIDENCE_RECORD = "https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json"

  depends_on "node"

  def install
    libexec.install Dir["*"]

    system Formula["node"].opt_bin/"npm", "install", "--omit=dev", "--ignore-scripts", "--no-audit", "--no-fund", chdir: libexec

    (bin/"noetica").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/cli/noetica.mjs" "$@"
    EOS
  end

  def caveats
    <<~EOS
      Noetica installed the workstation CLI:
        noetica version
        noetica configure
        noetica doctor
        noetica smoke --dry-run
        noetica start

      Homebrew is the installer/distribution path only. Do not use brew services
      as the canonical service supervisor for Noetica.

      Foreground mode:
        noetica start

      OS-native service mode:
        noetica service install
        noetica service start
        noetica service status
        noetica service stop
        noetica service uninstall

      Noetica uses OS-native service controls:
        macOS: launchctl / LaunchAgent
        Linux: systemd --user or SourceOS-compatible user service

      User configuration:
        ~/.config/sourceos/noetica/config.json

      Release package evidence:
        #{RELEASE_EVIDENCE_RECORD}
      Checksum record:
        #{RELEASE_EVIDENCE_RECORD}
      Rollback note:
        #{RELEASE_EVIDENCE_RECORD}
    EOS
  end

  test do
    assert_match '"name": "noetica"', shell_output("#{bin}/noetica version")
    assert_match '"kind": "NoeticaDoctor"', shell_output("#{bin}/noetica doctor --json")
    assert_match '"kind": "NoeticaSmoke"', shell_output("#{bin}/noetica smoke --dry-run")
  end
end
