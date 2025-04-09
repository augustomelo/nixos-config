{
  pkgs,
  config,
  ...
}:
{

  catppuccin = {
    bat.enable = true;
    flavor = "macchiato";
    fzf.enable = true;
    k9s.enable = true;
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

    stateVersion = "24.11";
    sessionVariables = {
      BAT_THEME = "Catppuccin Macchiato"; # this is needed for delta when running the command git blame
      EDITOR = "nvim";
      KUBECONFIG = "$HOME/.kube/config";
      JAVA_TOOL_OPTIONS="-javaagent:${pkgs.lombok}/share/java/lombok.jar -XX:UseSVE=0"; # use this until this PR is merged NixOS/nixpkgs#379073 or someone bump jdk version
    };

    packages = with pkgs; [
      cmake
      dasel
      dbeaver-bin
      delta
      docker-buildx
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
      jdk
      kubectl
      kubelogin-oidc
      lombok
      nixfmt-rfc-style
      nodejs_23
      python314
      ripgrep
      unzip
      vale
      xsel
      zsh-fzf-tab
    ];
  };

  imports = [
    ./activation/vale.nix
    ./programs
  ];

  nix.gc = {
    automatic = true;
    frequency = "daily";
    randomizedDelaySec = "10m";
    persistent = true;
    options = "--delete-older-than 3d";
  };

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
