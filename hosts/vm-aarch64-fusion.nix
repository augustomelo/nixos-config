{ pkgs, ... }:

{
  imports =
    [ 
      ./vm-base.nix
      ./hardware/vm-aarch64-fusion.nix
    ];

  hardware.graphics.enable = true;
  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    }; 
    vmware.guest.enable = true; 
  };

  networking = {
    hostName = "devbox"; 
    networkmanager.enable = true;
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

  environment = {
    variables = {
      GDK_SCALE = "2";
    };

    systemPackages = with pkgs; [
      (writeShellScriptBin "xrandr-auto" ''
       xrandr --output Virtual-1 --auto
       '')
    ];
  };

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
}
