{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./hardware/vm-aarch64-fusion.nix
  ];

  environment = {
    localBinInPath = true;
    variables = {
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
      QT_ENABLE_HIGHDPI_SCALING = 1;
    };
  };

  fileSystems."/mnt/shared" = {
    device = ".host:/";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [
      "umask=22"
      "uid=1000"
      "gid=100"
      "allow_other"
      "defaults"
      "auto_unmount"
    ];
  };

  networking = {
    firewall.enable = false;
    hostName = "devbox";
    networkmanager.enable = true;
  };

  programs. ssh.startAgent = true;

  security.sudo.wheelNeedsPassword = false;

  services = {
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
      xkb.layout = "us";
    };

    displayManager = {
      defaultSession = "none+i3";
    };
  };

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

  virtualisation.vmware.guest.enable = true;
}
