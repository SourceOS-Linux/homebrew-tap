class Bearbrowser < Formula
  desc "SourceOS governed browser overlay and agent-runtime tooling"
  homepage "https://github.com/SourceOS-Linux/BearBrowser"
  url "https://github.com/SourceOS-Linux/BearBrowser.git", branch: "main"
  version "0.1.0-overlay"
  license "MPL-2.0"
  head "https://github.com/SourceOS-Linux/BearBrowser.git", branch: "main"

  depends_on "git"
  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]

    (bin/"bearbrowser").write wrapper_for("apply-sourceos-overlays.sh")
    (bin/"bearbrowser-open").write wrapper_for("bearbrowser-open.sh")
    (bin/"bearbrowser-status").write wrapper_for("bearbrowser-status.sh")
    (bin/"bearbrowser-reset-bootstrap").write wrapper_for("bearbrowser-reset-bootstrap.sh")
    (bin/"bearbrowser-build-binary").write wrapper_for("bearbrowser-build-binary.sh")
    (bin/"bearbrowser-install-app-launcher").write wrapper_for("install-macos-app-launcher.sh")
    (bin/"bearbrowser-repair-app-launcher").write wrapper_for("repair-macos-app-launcher.sh")
    (bin/"bearbrowser-verify-build-lane").write wrapper_for("verify-build-lane.sh")
    (bin/"bearbrowser-check-build-env").write wrapper_for("check-build-environment.sh")
    (bin/"bearbrowser-discover-build-system").write wrapper_for("discover-upstream-build-system.sh")
    (bin/"bearbrowser-verify-upstream").write wrapper_for("verify-upstream-parity.sh")
    (bin/"bearbrowser-doctor").write wrapper_for("bearbrowser-doctor.sh")
    (bin/"bearbrowser-credential-doctor").write wrapper_for("bearbrowser-credential-doctor.sh")
    (bin/"bearbrowser-verify-credentials").write wrapper_for("verify-credential-broker.sh")
    (bin/"bearbrowser-verify-linux-packaging").write wrapper_for("verify-linux-packaging.sh")
    (bin/"bearbrowser-package-linux-all").write wrapper_for("package-linux-all.sh")
    (bin/"bearbrowser-update").write wrapper_for("bearbrowser-update.sh")
    (bin/"bearbrowser-automation-surfaces").write wrapper_for("bearbrowser-automation-surfaces.sh")
    (bin/"bearbrowser-install-runtime-deps").write wrapper_for("bearbrowser-install-runtime-deps.sh")
    (bin/"bearbrowser-lock-runtime-deps").write wrapper_for("bearbrowser-lock-runtime-deps.sh")
    (bin/"bearbrowser-playwright").write wrapper_for("bearbrowser-playwright.sh")
    (bin/"bearbrowser-stagehand").write wrapper_for("bearbrowser-stagehand.sh")
    (bin/"bearbrowser-terminal").write wrapper_for("bearbrowser-terminal.sh")
  end

  def wrapper_for(script)
    <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      exec bash "#{libexec}/scripts/#{script}" "$@"
    EOS
  end

  def caveats
    <<~EOS
      BearBrowser Formula installs the overlay/runtime tooling.
      Run bearbrowser-install-app-launcher to place BearBrowser.app in /Applications.
      Run bearbrowser-open to launch it, bearbrowser-status to inspect state, and bearbrowser-reset-bootstrap to stop old bootstrap Firefox profile processes.
      Run bearbrowser-doctor for system status and bearbrowser-verify-build-lane for build-lane readiness.
    EOS
  end

  test do
    assert_match "BearBrowser overlay plan", shell_output("#{bin}/bearbrowser --profile agent-runtime --ref latest --dry-run")
    assert_match "BearBrowser status", shell_output("#{bin}/bearbrowser-status")
    assert_match "BearBrowser build lane verified", shell_output("#{bin}/bearbrowser-verify-build-lane")
  end
end
