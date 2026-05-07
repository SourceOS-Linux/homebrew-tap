cask "bearbrowser" do
  version "0.1.0-overlay"
  sha256 :no_check
  release_evidence_record = "https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json"

  # Scaffold only. Replace with the signed/notarized macOS app release asset once BearBrowser.app exists.
  url "https://github.com/SourceOS-Linux/BearBrowser/releases/download/v#{version}/BearBrowser-#{version}-macos-universal.dmg"
  name "BearBrowser"
  desc "SourceOS governed browser for humans and agents"
  homepage "https://github.com/SourceOS-Linux/BearBrowser"

  app "BearBrowser.app"

  caveats <<~EOS
    This cask is a release scaffold. Publish a signed and notarized BearBrowser.app DMG before promoting it into SourceOS-Linux/homebrew-tap.
    Release package evidence: #{release_evidence_record}
    Checksum record: #{release_evidence_record}
    Rollback note: #{release_evidence_record}
  EOS
end
