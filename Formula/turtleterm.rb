# frozen_string_literal: true

class Turtleterm < Formula
  desc "SourceOS policy-aware agent terminal fabric"
  homepage "https://github.com/SourceOS-Linux/TurtleTerm"
  license "MIT"

  stable do
    url "https://github.com/SourceOS-Linux/TurtleTerm/archive/refs/tags/turtle-term-v0.2.0.tar.gz"
    sha256 "fb63be1fddc72c77bacf87ff91cbb63988825af607ed2e193600336abf18dc52"
    version "0.2.0"
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
      turtle-synapseiq
      synapseiq-lsp
      turtle-plan-view
      turtle-selftest
      turtle-runbook
      turtle-voice
      turtle-sync
      turtle-perf
      turtle-persona
      turtle-files
      turtle-bg
      turtle-dash
      turtle-pr
      turtle-issue
      turtle-hooks
      turtle-gitea
      turtle-ci
      turtle-review
      turtle-watch
      turtle-cost
      turtle-copilot
      turtle-gh
      turtle-env
      turtle-diagnose
      turtle-apply
      turtle-chain
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
    pkgshare.install "assets/sourceos/mcp" => "mcp" if Dir.exist?("assets/sourceos/mcp")
    pkgshare.install "assets/sourceos/neovim" => "neovim" if Dir.exist?("assets/sourceos/neovim")

    # Bundle SynapseIQ LSP server if the repo was present at build time
    synapseiq_server = buildpath.parent/"synapseiq/packages/lsp/src/server.js"
    if synapseiq_server.exist?
      (pkgshare/"synapseiq").mkpath
      (pkgshare/"synapseiq").install synapseiq_server
    end

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
      TurtleTerm v1.4.0 installed.

      Profile:     #{etc}/turtle-term/turtleterm.lua
      Shell inits: #{pkgshare}/shell/
      MCP server:  #{bin}/turtle-mcp-server

      Shell integration — add to your shell rc:
        source #{pkgshare}/shell/turtle-shell-init.zsh   # zsh  (debounced AI ghost-text, ALT+/)
        source #{pkgshare}/shell/turtle-shell-init.bash  # bash  (ALT+/ explicit, ALT+G background)
        source #{pkgshare}/shell/turtle-shell-init.fish  # fish  (ALT+/ explicit, ALT+G background)

      Claude Code MCP — add to ~/.claude/settings.json:
        {
          "mcpServers": {
            "turtleterm": {
              "type": "stdio",
              "command": "#{bin}/turtle-mcp-server"
            }
          }
        }

      AI features:
        Set ANTHROPIC_API_KEY for Claude-powered explain/NL-to-shell.
        Fallback: SOURCEOS_NOETICA_URL (default http://localhost:8080)

      Gitea sovereign forge (primary — GitHub is fallback only):
        export GITEA_URL=http://your-gitea:3000
        export GITEA_TOKEN=your-token
        turtle-gitea status             Check Gitea connection + version
        turtle-gitea repos              List repositories
        turtle-gitea pr list            List open PRs
        turtle-gitea pr create          Create PR from current branch
        turtle-gitea release --tag v1.0 Create a release
        turtle-gitea ci                 Show recent CI runs
        turtle-gitea ci watch RUN_ID    Watch a CI run to completion

      CI/CD pipeline view:
        turtle-ci                       List recent CI runs (Gitea Actions primary, gh fallback)
        turtle-ci watch                 Watch latest run live
        turtle-ci pass                  Block until latest run passes or fails

      AI-annotated PR review:
        turtle-review                   Review latest open PR with AI annotation
        turtle-review 42                Review PR #42
        turtle-review --diff            Review staged local diff

      Process supervisor:
        turtle-watch "npm run dev"      Run + auto-restart on crash
        turtle-watch list               Show all supervised processes

      API cost tracker:
        turtle-cost                     Show AI API cost summary across sessions
        turtle-cost today               Today's cost breakdown by model
        turtle-cost reset               Clear cost log

      Self-hosted AI co-pilot (multi-backend: Claude, Ollama, Noetica):
        turtle-copilot start            Start always-on watcher (auto-explains errors)
        turtle-copilot chat             Multi-turn conversation with your co-pilot
        turtle-copilot suggest          View latest proactive suggestions
        turtle-copilot backends         List available AI backends
        turtle-copilot use ollama       Switch to local Ollama model (no cloud needed)
        turtle-copilot use noetica      Switch to self-hosted Noetica backend

      gh CLI parity (Gitea primary, GitHub fallback):
        turtle-gh status                Forge status: open PRs, issues, co-pilot state
        turtle-gh repo create NAME      Create a repo on Gitea
        turtle-gh pr create --ai        Create PR with AI-generated body
        turtle-gh pr list               List open PRs
        turtle-gh issue list            List issues
        turtle-gh release create --ai-changelog   Release with AI-generated changelog
        turtle-gh search repos QUERY    Semantic repo search (AI-ranked)
        turtle-gh run watch             Watch CI run live

      Cross-session tools:
        turtle-persona install devops   Install DevOps AI persona
        turtle-voice                    Voice-to-shell (requires sox + whisper-cpp)
        turtle-sync push --remote URL   Sync config across machines
        turtle-perf stats               View command performance stats
        turtle-files [DIR]              Browse files inline

      Keybinds (in TurtleTerm):
        CMD+↑ / CMD+↓          Jump between prompt marks
        CMD+B                   Copy last command output to clipboard
        CTRL+SHIFT+N            Natural language → shell command
        CTRL+SHIFT+Z            Pre-exec risk check
        CTRL+SHIFT+V            Environment inspector
        CTRL+SHIFT+D            Docker picker
        CTRL+SHIFT+H            SSH picker
        CTRL+SHIFT+B/K          Bookmark save/browse
        CTRL+ALT+F              Fuzzy output search
        CTRL+ALT+T              File browser
        CTRL+ALT+X              Explain command in prompt
        CMD+SHIFT+X             Export output (markdown/JSON/HTML/Gist)
        CMD+[                   Collapse/expand output block
        CMD+SHIFT+C             Copy output block
        CMD+SHIFT+ALT+P         Plugin command palette
        CTRL+SHIFT+ALT+S        SFTP browser (in SSH panes)
        F4                      Voice-to-shell (Whisper.cpp)
        F5                      Session narrative (AI summary)
        F6                      AI Terminal Coach

      Language intelligence (SynapseIQ LSP):
        turtle-synapseiq start          Start on port 2087
        turtle-synapseiq status         Check reachability
        turtle-language diagnostics file.py
        turtle-language symbols file.ts

      Neovim plugin:
        source #{pkgshare}/neovim/plugin/turtle.vim
        " or with vim-plug: Plug 'SourceOS-Linux/TurtleTerm', {'rtp': 'assets/sourceos/neovim'}

      Shell integration (first-run):
        turtleterm --install-shell-integration

      Project environment management:
        turtle-env init                 Create .turtle/env.yaml in project root
        turtle-env set KEY VALUE        Set a project env var
        eval $(turtle-env load)         Load project env into shell
        turtle-env scan                 Detect env vars used in source files
        turtle-env diff                 Compare project vs shell env

      Diagnostics:
        turtle-diagnose                 Full health check all integrations
        turtle-diagnose --fix           Show fix suggestions for failing checks

      AI patch application:
        turtle-apply                    Apply latest co-pilot suggestion to files
        turtle-apply --dry-run          Preview changes without writing
        cat fix.patch | turtle-apply    Apply a unified diff from stdin

      Agent action pipelines:
        turtle-chain workspace-scan -- copilot-chat message="{project_type}"
        turtle-chain --run pr-auto     Run saved pipeline
        turtle-chain --list            List all saved + built-in pipelines
        turtle-chain --save NAME STEPS Save a custom pipeline

      Quick smoke test:
        turtle-agentctl --stdio ping
        turtle-agentctl explain-selection "No such file or directory"
        turtle-agentctl nl-to-shell "show disk usage by directory"
        turtle-agentctl atlas-context .
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
    ENV["SOURCEOS_EXECUTION_DOMAIN"] = "host"
    ENV["ANTHROPIC_API_KEY"] = ""

    assert_match "turtle-agentd", shell_output("#{bin}/turtle-agentctl --stdio ping")
    assert_match "surfaces", shell_output("#{bin}/turtle-agentctl --stdio surfaces")
    assert_match "explain_selection", shell_output("#{bin}/turtle-agentctl --stdio explain-selection 'test output'")
    assert_match "nl_to_shell", shell_output("#{bin}/turtle-agentctl --stdio nl-to-shell 'list files by size'")
    assert_match "atlas_context", shell_output("#{bin}/turtle-agentctl --stdio atlas-context #{testpath}")
    assert_match "diagnostics", shell_output("#{bin}/turtle-language diagnostics #{__FILE__}")
    assert_path_exists "#{pkgshare}/shell/turtle-shell-init.zsh"
    assert_path_exists "#{pkgshare}/shell/turtle-shell-init.bash"
    assert_path_exists "#{pkgshare}/shell/turtle-shell-init.fish"
    assert_path_exists "#{bin}/turtle-mcp-server"
  end
end
