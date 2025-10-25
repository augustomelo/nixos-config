{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./tools/bash
    ./tools/bat
    ./tools/direnv
    ./tools/fzf
    ./tools/ghostty
    ./tools/git
    ./tools/jujutsu
    ./tools/neovim
    ./tools/podman
    ./tools/starship
    ./tools/tmux
    ./tools/vale
    ./tools/zoxide
    ./windowManager/i3
  ];

  options.developerTools = {
    enable = lib.mkEnableOption "Enable developer tools";
    windowManager.i3.enable = lib.mkEnableOption "Enable i3 window manager";
  };

  config = lib.mkIf config.developerTools.enable {
    catppuccin = {
      flavor = "macchiato";

      bat.enable = true;
      fzf.enable = true;
      kvantum.enable = false;
      tmux = {
        enable = true;
        extraConfig = ''
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_text " #W"
          set -g @catppuccin_window_current_text " #W"
        '';
      };
    };

    home.packages = with pkgs; [
      cmake
      dasel
      dbeaver-bin
      delta
      docker-compose
      eza
      fd
      firefox
      gcc
      gnumake
      go
      home-manager
      hurl
      nixfmt-rfc-style
      nodejs_22
      python313
      ripgrep
      sops
      unzip
      xsel
      jsonnet
    ];
  };
}
