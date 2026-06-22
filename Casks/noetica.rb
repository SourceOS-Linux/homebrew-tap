cask "noetica" do
  version "0.4.11"
  sha256 :no_check

  url "https://github.com/SocioProphet/Noetica/releases/download/v#{version}/Noetica_#{version}_universal.dmg",
      verified: "github.com/SocioProphet/Noetica/"

  name "Noetica"
  desc "Self-hosted AI dialogue management backend — 22-intent layer"
  homepage "https://github.com/SocioProphet/Noetica"

  depends_on macos: :ventura

  app "Noetica.app"

  postflight do
    # Set SOURCEOS_NOETICA_URL for shell sessions
    noetica_url = "http://localhost:8080"
    zshrc  = "#{Dir.home}/.zshrc"
    bashrc = "#{Dir.home}/.bashrc"
    export_line = "\nexport SOURCEOS_NOETICA_URL=\"#{noetica_url}\"  # Noetica\n"
    [zshrc, bashrc].each do |rc|
      next unless File.exist?(rc)
      content = File.read(rc)
      File.open(rc, "a") { |f| f.write(export_line) } unless content.include?("SOURCEOS_NOETICA_URL")
    end
  end

  uninstall quit: "ai.noetica.app"

  zap trash: [
    "~/Library/Application Support/ai.noetica.app",
    "~/Library/Logs/ai.noetica.app",
    "~/Library/Preferences/ai.noetica.app.plist",
    "~/Library/Saved Application State/ai.noetica.app.savedState",
    "~/.noetica",
    "~/.config/noetica",
  ]

  caveats <<~EOS
    Noetica runs as a local service on port 8080.

    After launch:
      curl http://localhost:8080/health

    TurtleTerm integration — add to your shell rc:
      export SOURCEOS_NOETICA_URL="http://localhost:8080"

    Then use with TurtleTerm co-pilot:
      turtle-copilot use noetica
      turtle-copilot start

    If macOS Gatekeeper blocks the app:
      sudo xattr -dr com.apple.quarantine /Applications/Noetica.app
  EOS
end
