{ pkgs, ... }:

{
  imports =
    [ 
      ./hardware/vm-aarch64-fusion.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "devbox"; 
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Lisbon";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_PT.UTF-8";
      LC_IDENTIFICATION = "pt_PT.UTF-8";
      LC_MEASUREMENT = "pt_PT.UTF-8";
      LC_MONETARY = "pt_PT.UTF-8";
      LC_NAME = "pt_PT.UTF-8";
      LC_NUMERIC = "pt_PT.UTF-8";
      LC_PAPER = "pt_PT.UTF-8";
      LC_TELEPHONE = "pt_PT.UTF-8";
      LC_TIME = "pt_PT.UTF-8";
    };
  };

  security = {
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  hardware.graphics.enable = true;
  nixpkgs.config.allowUnfree = true;

  virtualisation.vmware.guest.enable = true;
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
      neovim 
        xsel
        git
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

  system.stateVersion = "24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
