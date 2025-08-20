{
  pkgs,
  ...
}:
{
  catppuccin = {
    flavor = "macchiato";

    bat.enable = true;
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

    stateVersion = "25.05";
    sessionVariables = {
      BAT_THEME = "Catppuccin Macchiato"; # this is needed for delta when running the command git blame
      EDITOR = "nvim";
      KUBECONFIG = "$HOME/.kube/config";
      JAVA_TOOL_OPTIONS = "-javaagent:${pkgs.lombok}/share/java/lombok.jar";
    };

    packages = with pkgs; [
      cmake
      dasel
      dbeaver-bin
      delta
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
      nodejs_22
      podman
      podman-compose
      python314
      ripgrep
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
