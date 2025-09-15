{ pkgs, ... }:
{
  programs = {
    git.enable = true;
    bash.shellAliases = {
      la = "ls -la ";
      ll = "ls -l";
      nfu = "nix flake update --flake $HOME/workspace/personal/nixos-config/";
      nrs = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nixos-config/#";
    };
    ssh.startAgent = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      2283
      5055
      6767
      7878
      8080
      8989
      9696
    ];
  };


  # Needed by podman-user-wait-network-online.service
  # https://github.com/containers/podman/issues/24796
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  systemd.network = {
    enable = true;
    wait-online = {
      enable = true;
      anyInterface = true;
    };
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp3s0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  users = {
    mutableUsers = false;
    users.jb = {
      home = "/home/jb";
      linger = true;
      isNormalUser = true;
      shell = pkgs.bash;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = "/etc/nixos/passwd";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGL2rZ4htp01YDa9Q6iqwcmtpkawn6VdCu25idKDHKm jb@home-server"
      ];
    };
  };
}
