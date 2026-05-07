cask "bearbrowser" do
  version "0.1.0-overlay"
  sha256 :no_check

  # Scaffold only. Replace with the signed/notarized macOS app release asset once BearBrowser.app exists.
  url "https://github.com/SourceOS-Linux/BearBrowser/releases/download/v#{version}/BearBrowser-#{version}-macos-universal.dmg"
  name "BearBrowser"
  desc "SourceOS governed browser for humans and agents"
  homepage "https://github.com/SourceOS-Linux/BearBrowser"

  app "BearBrowser.app"

  caveats <<~EOS
    This cask is a release scaffold. Publish a signed and notarized BearBrowser.app DMG before promoting it into SourceOS-Linux/homebrew-tap.
    Release package evidence: https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json
    Checksum record: https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json
    Rollback note: https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json
  EOS
end
