{
  pkgs,
  ...
}:
{
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

  home = {
    file.".config" = {
      source = ./config;
      recursive = true;
    };

    stateVersion = "25.05";
    sessionVariables = {
      BAT_THEME = "Catppuccin Macchiato"; # this is needed for delta when running the command git blame
      EDITOR = "nvim";
    };

    packages = with pkgs; [
      cmake
      dasel
      dbeaver-bin
      delta
      docker-compose
      eza
      fd
      firefox
      fzf-git-sh
      gcc
      git
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
      vale
      xsel
    ];
  };

  imports = [
    ./activation/vale.nix
    ./programs
  ];

  xdg.enable = true;

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      terminal = "ghostty";
      modifier = "Mod4";
      startup = [
        { command = "exec xrandr --dpi 220"; }
      ];
    };
  };
}
