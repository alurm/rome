{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    lsbig.url = "github:alurm/lsbig";
    lsbig.inputs.nixpkgs.follows = "nixpkgs";

    json2dir.url = "github:alurm/json2dir";
    # Not used to use Cachix.
    # json2dir.inputs.nixpkgs.follows = "nixpkgs";

    # jj fork with colocated worktrees.
    # https://github.com/jj-vcs/jj/pull/8667 plus CLI changes.
    jj.url = "github:alurm/jj?ref=codex/workspace-cli-sync-head";
  };

  outputs = {
    nixpkgs,
    lsbig,
    json2dir,
    jj,
    ...
  }: let
    system = "aarch64-darwin";

    pkgs = import nixpkgs {
      inherit system;

      # Unfree software can be listed here.
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["claude-code"];
    };

    lib = pkgs.lib;

    info = let
      enquote = lib.escapeShellArg;
    in {
      inherit enquote;
      enpath = x: enquote (builtins.concatStringsSep "/" x);
      system-dir = ["Code"]; # Location of the "system directory" relative to home directory.
      full-name = "Alan Urmancheev";
      email = "alan.urman@gmail.com";
      username = "alurm";
    };

    home = import ./home (info // {inherit nixpkgs pkgs lib;});
  in {
    inherit home;

    # https://nixos.org/manual/nixpkgs/stable/#sec-declarative-package-management
    # symlinkJoin can be used instead, but it doesn't fail on duplicate paths.
    packages.${system}.default = pkgs.buildEnv {
      name = "profile";
      paths = with pkgs; [
        # A dummy package to capture all the deps of `home`

        (import ./packages/home.nix {inherit system pkgs home;})

        # A way to apply dotfiles

        (import ./packages/apply-dotfiles.nix {
          inherit
            json2dir
            system
            writeShellApplication
            ;
          my = info;
        })

        # Some of my own software

        lsbig.packages.${system}.default
        json2dir.packages.${system}.default

        # Other scripts and wrappers

        (import ./packages/my-acme.nix pkgs)
        (import ./packages/be-awake-until-lid-opens.nix pkgs)

        # A `jujutsu` fork
        
        jj.packages.${system}.default

        # Some tools

        atool
        rlwrap
        ffmpeg
        typst
        yt-dlp-light
        claude-code # Do I even need this?
        gh

        # Questionable

        # Lol. Lmao, even.
        #
        # https://access.redhat.com/security/cve/cve-2025-41390
        (pkgs.writeShellApplication {
          name = "git";
          text = ''
            exec ${pkgs.git}/bin/git -c core.fsmonitor=false "$@"
          '';
        })

        # Text editing

        helix
        emacs

        # ## Emacs
        #
        # emacs.pkgs.vterm
        # emacs.pkgs.treesit-grammars.with-all-grammars
        # emacs.pkgs.nix-ts-mode

        # Neovim

        # (neovim.override {
        #   configure = {
        #     customRC = ''
        #       luafile ~/.config/nvim/init.lua
        #     '';
        #     packages.plugins = with pkgs.vimPlugins; {
        #       start = [
        #         nvim-treesitter.withAllGrammars
        #         telescope-nvim
        #         nvim-lspconfig
        #         oil-nvim
        #       ];
        #     };
        #   };
        # })

        # Used rarely or niche

        tmux
        nushell
        caddy
        bat
        ripgrep
        cloc
        entr
        exiftool
        eyed3
        moreutils
        imagemagick
        fd
        pandoc
        rclone
        tiddlywiki
        xz
        act
        android-tools
        cachix
        coreutils
        devcontainer
        dos2unix
        hyperfine
        jjui
        lldb # Do we need this?
        pigz
        pngpaste
        qemu
        sccache # We are apparently using this with `cargo`.
        scrcpy
        sshfs
        w3m
        yamlfmt
        zoxide

        # Programming and configuration languages, their runtimes and tooling

        lua5_4
        jq
        gawk
        cue
        ghc
        ghostscript
        nodejs
        bash
        deno
        hadolint # A linter for Docker.
        php

        # Go

        go
        gopls

        # Zig

        zig
        zls

        # Python

        python3
        pyright
        ruff
        # ty
        uv

        # Bash

        bash-language-server
        shfmt
        shellcheck

        # Nix

        direnv
        devenv
        nix-direnv
        nil
        nix-tree
        nixd # Do we need this?

        ## A formatter. Seems to be better to me than nixfmt-rfc-style

        alejandra

        # Web, JavaScript, TypeScript

        prettier
        typescript
        typescript-language-server
        vscode-langservers-extracted
        eslint # Do I need this?
      ];
    };
  };
}
