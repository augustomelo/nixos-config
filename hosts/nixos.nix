{ pkgs, ... }:

{
  imports =
    [ 
      ./hardware/aarch64-linux-utm.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos"; 
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

  security.polkit.enable = true;
  hardware.opengl.enable = true;

  services = {
    spice-vdagentd.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    # variables.LIBGL_ALWAYS_SOFTWARE = "1";
    systemPackages = with pkgs; [
      neovim 
        xsel
        git
    ];
  };

  system.stateVersion = "24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
