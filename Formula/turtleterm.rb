# frozen_string_literal: true

class Turtleterm < Formula
  desc "SourceOS policy-aware agent terminal fabric"
  homepage "https://github.com/SourceOS-Linux/TurtleTerm"
  license "MIT"

  stable do
    url "https://github.com/SourceOS-Linux/TurtleTerm/archive/refs/tags/turtle-term-v0.1.1.tar.gz"
    sha256 "b9b9d40e3c9e66bcd87e3ca0df1e19a95c3f2fd6d16f1ae87d0ede9c4dda6009"
    version "0.1.1"
  end

  head "https://github.com/SourceOS-Linux/TurtleTerm.git", branch: "main"

  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  on_macos do
    depends_on "cmake" => :build
  end

  on_linux do
    depends_on "cmake" => :build
    depends_on "fontconfig"
    depends_on "freetype"
    depends_on "libx11"
    depends_on "libxcb"
    depends_on "libxkbcommon"
    depends_on "openssl@3"
    depends_on "python@3.12"
    depends_on "wayland"
    depends_on "xcb-util"
    depends_on "xcb-util-image"
    depends_on "zlib"
  end

  def install
    ENV["OPENSSL_NO_VENDOR"] = "1" if OS.linux?

    system "cargo", "build", "--release", "--locked", "-p", "wezterm"
    system "cargo", "build", "--release", "--locked", "-p", "wezterm-gui"
    system "cargo", "build", "--release", "--locked", "-p", "wezterm-mux-server"

    (libexec/"turtle-term").install "target/release/wezterm"
    (libexec/"turtle-term").install "target/release/wezterm-gui"
    (libexec/"turtle-term").install "target/release/wezterm-mux-server"

    turtle_scripts = %w[
      sourceos-term
      turtle-term
      turtle-agentd
      turtle-agentctl
      turtle-tmux
      turtle-cloudfog
      turtle-superconscious
      turtle-agent-machine
      turtle-language
      turtle-session
    ]
    turtle_scripts.each do |script|
      script_path = "assets/sourceos/bin/#{script}"
      next unless File.exist?(script_path)

      chmod 0755, script_path
      bin.install script_path
    end

    libexec.install "assets/sourceos/bin/turtleterm" => "turtleterm"
    libexec.install "assets/sourceos/bin/turtleterm-mux-server" => "turtleterm-mux-server"
    chmod 0755, libexec/"turtleterm"
    chmod 0755, libexec/"turtleterm-mux-server"

    (bin/"turtleterm").write <<~EOS
      #!/bin/sh
      export TURTLE_TERM_RUNTIME_DIR="#{libexec}/turtle-term"
      export TURTLETERM_CONFIG="#{etc}/turtle-term/turtleterm.lua"
      exec "#{libexec}/turtleterm" "$@"
    EOS
    (bin/"turtleterm-mux-server").write <<~EOS
      #!/bin/sh
      export TURTLE_TERM_RUNTIME_DIR="#{libexec}/turtle-term"
      exec "#{libexec}/turtleterm-mux-server" "$@"
    EOS

    profile_source = if File.exist?("assets/sourceos/turtleterm.lua")
      Pathname("assets/sourceos/turtleterm.lua")
    elsif File.exist?("assets/sourceos/wezterm.lua")
      Pathname("assets/sourceos/wezterm.lua")
    else
      profile = buildpath/"turtleterm.lua"
      profile.write <<~LUA
        local wezterm = require 'wezterm'
        local config = wezterm.config_builder()
        config.set_environment_variables = {
          SOURCEOS_TERMINAL_FRONTEND = 'turtle-term',
          SOURCEOS_TERMINAL_PROFILE = 'turtleterm-homebrew-fallback',
          TURTLETERM_PROFILE = 'turtleterm-homebrew-fallback',
        }
        return config
      LUA
      profile
    end
    (etc/"turtle-term").mkpath
    (etc/"turtle-term/turtleterm.lua").write profile_source.read

    pkgshare.install "docs/sourceos"

    if File.exist?("assets/sourceos/mcp/turtle-mcp-server")
      chmod 0755, "assets/sourceos/mcp/turtle-mcp-server"
      bin.install "assets/sourceos/mcp/turtle-mcp-server"
    end

    pkgshare.install "assets/sourceos/shell" => "shell" if Dir.exist?("assets/sourceos/shell")
    pkgshare.install "assets/sourceos/skills" => "skills" if Dir.exist?("assets/sourceos/skills")
    pkgshare.install "assets/sourceos/brand" => "brand" if Dir.exist?("assets/sourceos/brand")
    pkgshare.install "assets/sourceos/desktop" => "desktop" if Dir.exist?("assets/sourceos/desktop")

    if OS.linux?
      if File.exist?("assets/sourceos/desktop/ai.sourceos.TurtleTerm.desktop")
        (share/"applications").install "assets/sourceos/desktop/ai.sourceos.TurtleTerm.desktop"
      end
      if File.exist?("assets/sourceos/desktop/ai.sourceos.TurtleTerm.metainfo.xml")
        (share/"metainfo").install "assets/sourceos/desktop/ai.sourceos.TurtleTerm.metainfo.xml"
      end
      if File.exist?("assets/sourceos/brand/ai.sourceos.TurtleTerm.svg")
        (share/"icons/hicolor/scalable/apps").install "assets/sourceos/brand/ai.sourceos.TurtleTerm.svg"
      end
    end
  end

  def caveats
    <<~EOS
      TurtleTerm v0.1.1 installed.

      Profile:   #{etc}/turtle-term/turtleterm.lua
      Docs:      #{pkgshare}/sourceos/
      Skills:    #{pkgshare}/skills/
      Shell:     #{pkgshare}/shell/

      Quick smoke test:
        turtle-term paths
        turtle-agentctl --stdio ping
        turtle-agentctl --stdio noetica-status
        turtle-agentctl --stdio policy-status
        turtle-language synapseiq-status

      Shell integration (add to ~/.zshrc / ~/.bashrc):
        source #{pkgshare}/shell/turtle-shell-init.zsh    # zsh
        source #{pkgshare}/shell/turtle-shell-init.bash   # bash

      Claude Code MCP — add to ~/.claude/settings.json:
        {
          "mcpServers": {
            "turtleterm": {
              "type": "stdio",
              "command": "#{bin}/turtle-mcp-server"
            }
          }
        }

      Noetica (cognition loop): set SOURCEOS_NOETICA_URL (default http://localhost:8080)
      Policy Fabric:            set SOURCEOS_POLICY_FABRIC_URL (default http://localhost:8081)
      SynapseIQ LSP:            set SOURCEOS_SYNAPSEIQ_URL (default http://localhost:2087)
    EOS
  end

  test do
    assert_match "TurtleTerm command wrapper", shell_output("#{bin}/turtle-term --help")
    assert_match "TurtleTerm local agent gateway", shell_output("#{bin}/turtle-agentd --help")
    assert_match "TurtleTerm agent gateway CLI", shell_output("#{bin}/turtle-agentctl --help")

    events = testpath/"events.ndjson"
    receipts = testpath/"receipts"
    ENV["SOURCEOS_TERMINAL_SESSION_ID"] = "turtle-term-brew-test"
    ENV["SOURCEOS_WORKSPACE"] = "turtle-term-brew"
    ENV["SOURCEOS_TERMINAL_EVENTS"] = events.to_s
    ENV["SOURCEOS_TERMINAL_RECEIPTS"] = receipts.to_s
    ENV["SOURCEOS_ACTOR_ID"] = "test:homebrew"
    ENV["SOURCEOS_POLICY_BUNDLE_ID"] = "policy:homebrew-test"
    ENV["SOURCEOS_EXECUTION_DOMAIN"] = "host"

    assert_match "turtle-agentd", shell_output("#{bin}/turtle-agentctl --stdio ping")
    assert_match "surfaces", shell_output("#{bin}/turtle-agentctl --stdio surfaces")
    assert_match "diagnostics", shell_output("#{bin}/turtle-language diagnostics #{__FILE__}")
    assert_match "profiles", shell_output("#{bin}/turtle-session profiles")
  end
end
