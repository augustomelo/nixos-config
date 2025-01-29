{ pkgs, ... }:
{
  programs = {
    ssh.startAgent = true;
    zsh = {
      enable =  true;
      histSize = 50000;
      histFile="$XDG_STATE_HOME/zsh/history";
    };
  };

  users = {
    mutableUsers = false;
    users.augusto = {
      home = "/home/augusto";
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$5qUofB6UibbNyT6gQ7nDX/$QpaTGYmim85ItVepaLalPmtPg1D/A6eFJj6YsCWMQfB";
    };
  };
}
