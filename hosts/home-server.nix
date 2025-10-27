{
  config,
  ...
}:
{
  imports = [
    ./shared.nix
    ./hardware/gmktec-nucbox-g3-plus.nix
  ];

  networking = {
    firewall = {
      enable = true;
      allowedUDPPorts = [
        5454
      ];
      allowedTCPPorts = [
        2283
        4445
        5055
        5454
        6767
        7878
        8000
        8008
        8080
        8096
        8888
        8989
        9696
        9999
      ];
    };
    hostName = "home-server";
    nftables = {
      enable = true;
      tables = {
        forward-ports = {
          family = "inet";
          content = ''
            chain prerouting {
              type nat hook prerouting priority dstnat; policy accept;
              tcp dport 53 redirect to :5454
              tcp dport 80 redirect to :8008
              tcp dport 445 redirect to :4445
              udp dport 53 redirect to :5454
            }
          '';
        };
      };
    };
    useDHCP = false;
  };

  programs = {
    git.enable = true;
    bash.shellAliases = {
      la = "ls -la ";
      ll = "ls -l";
      nfu = "nix flake update --flake /nixos-config/";
      nrs = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nixos-config/#";
    };
    ssh.startAgent = true;
  };

  services = {
    fail2ban.enable = true;
    openssh = {
      enable = true;
      ports = [ 33177 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "augusto" ];
      };
    };
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
    };
  };

  sops = {
    age.keyFile = "/etc/nixos/key.txt";
    defaultSopsFile = ../secrets/home-server.yaml;
    defaultSopsFormat = "yaml";
    secrets.tailscaleAuthKey = { };
  };

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

  # Needed by podman-user-wait-network-online.service
  # https://github.com/containers/podman/issues/24796
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  users = {
    users.augusto = {
      linger = true;
      extraGroups = [
        "podman"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGL2rZ4htp01YDa9Q6iqwcmtpkawn6VdCu25idKDHKm jb@home-server"
      ];
    };
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      autoPrune.enable = true;
    };
  };
}
