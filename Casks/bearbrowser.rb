cask "bearbrowser" do
  version "150.0.7"
  sha256 "9e42e4333b70d43da882d478b4ca15f6ba874cbfb4fc6573a08ca3961c1e94a7"

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
