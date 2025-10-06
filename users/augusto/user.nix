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
      # https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode
      subUidRanges = [
        {
          startUid = 10000;
          count = 75535;
        }
      ];
      subGidRanges = [
        {
          startGid = 10000;
          count = 75535;
        }
      ];
    };
  };
}
