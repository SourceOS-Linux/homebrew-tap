cask "bearbrowser" do
  version "150.0.5"
  sha256 "e9c1270a55ee71d07426dd4d98e5fbe239a97c64068ffbcfef77db16da23e379"

  url "https://github.com/SourceOS-Linux/BearBrowser/releases/download/v#{version}/BearBrowser-#{version}-macos.dmg",
      verified: "github.com/SourceOS-Linux/BearBrowser/"
  name "BearBrowser"
  desc "Sovereign, privacy-first Firefox fork with a live network monitor and honeypot"
  homepage "https://github.com/SourceOS-Linux/BearBrowser"

  depends_on macos: :catalina

  # BearBrowser is a LibreWolf-mirror Firefox 150 fork: hardened anti-fingerprinting,
  # BearNet (a built-in loopback network monitor + world map + OSINT), and BearTrap
  # (a fingerprint-probe honeypot that also blocks canary-token exfiltration).
  app "BearBrowser.app"

  caveats <<~EOS
    BearBrowser is currently shipped UNSIGNED (no paid Apple Developer cert yet).
    Homebrew removes the download quarantine on install, so `brew` launches it fine.
    If macOS still blocks it, right-click the app and choose Open, or run:
      xattr -dr com.apple.quarantine "#{appdir}/BearBrowser.app"

    Release + checksum + rollback evidence:
      https://github.com/SourceOS-Linux/homebrew-tap/blob/main/release-evidence/workspace-operations.json
  EOS
end
