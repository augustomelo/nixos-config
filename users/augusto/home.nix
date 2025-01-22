{
  pkgs,
  username,
  ...
}: {

  home = {
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
    username = username;

    sessionVariables = {
      GSK_RENDERER = "gl";
    };

    packages = with pkgs; [
      home-manager
      foot
    ];
  };


  programs = {
    ghostty = {
      enable = true;
    };
  };

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      terminal = "ghostty";
      modifier = "Mod4";
    };
  };
}
