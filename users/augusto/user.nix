{ pkgs, ... }:
{
  programs = {
    ssh.startAgent = true;
  };

  virtualisation.docker.enable = true;

  # https://discourse.nixos.org/t/docker-ignoring-platform-when-run-in-nixos/21120/14
  # https://docs.docker.com/build/building/multi-platform/#qemu 

  users = {
    mutableUsers = false;
    users.augusto = {
      home = "/home/augusto";
      isNormalUser = true;
      shell = pkgs.bash;
      extraGroups = [
        "docker"
        "wheel"
      ];
      hashedPassword = "$y$j9T$5qUofB6UibbNyT6gQ7nDX/$QpaTGYmim85ItVepaLalPmtPg1D/A6eFJj6YsCWMQfB";
    };
  };
}
