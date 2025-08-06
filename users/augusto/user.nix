{ pkgs, ... }:
{
  programs = {
    ssh.startAgent = true;
  };

  users = {
    mutableUsers = false;
    users.augusto = {
      home = "/home/augusto";
      isNormalUser = true;
      shell = pkgs.bash;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$5qUofB6UibbNyT6gQ7nDX/$QpaTGYmim85ItVepaLalPmtPg1D/A6eFJj6YsCWMQfB";
    };
  };
}
