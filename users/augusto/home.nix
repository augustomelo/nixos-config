{
  pkgs,
  username,
  ...
}: {

  home = {
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
    username = username;

    packages = with pkgs; [
      home-manager
    ];
  };

  programs = {
    ghostty = {
      enable = true;
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      terminal = "ghostty";
      modifier = "Mod4";
      output = {
        "Virtual-1" = {
          mode = "1920x1080@60Hz";
        };
      };
    };
  };
}

