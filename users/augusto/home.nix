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
      neovim 
      xsel
      git
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
      startup = [
        { command = "exec xrandr --dpi 192"; }
      ];
    };
  };
}
