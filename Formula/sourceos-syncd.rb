class SourceosSyncd < Formula
  desc "SourceOS sync daemon packaging scaffold"
  homepage "https://github.com/SourceOS-Linux/sourceos-syncd"
  url "https://github.com/SourceOS-Linux/sourceos-syncd.git", branch: "main"
  version "0.1.0-dev"
  license "MIT"
  head "https://github.com/SourceOS-Linux/sourceos-syncd.git", branch: "main"

  RELEASE_EVIDENCE = "https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json"
  CHECKSUM_RECORD = "https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json"
  ROLLBACK_NOTE = "https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json"

  def install
    libexec.install Dir["*"]
    (bin/"sourceos-syncd").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      echo "sourceos-syncd source staged at #{libexec}"
    EOS
  end

  def caveats
    <<~EOS
      sourceos-syncd release/package scaffold only. Runtime governance remains in the source repository contracts and CI gates.

      Release package evidence:
        #{RELEASE_EVIDENCE}
      Checksum record:
        #{CHECKSUM_RECORD}
      Rollback note:
        #{ROLLBACK_NOTE}
    EOS
  end

  test do
    assert_match "sourceos-syncd source staged", shell_output("#{bin}/sourceos-syncd")
  end
end
