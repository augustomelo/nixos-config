{ ... }:
{
  imports = [
    ./shared.nix
    ./hardware/gmktec-nucbox-g3-plus.nix
  ];

  networking.hostName = "home-server";

  services = {
    fail2ban.enable = true;
    openssh = {
      enable = true;
      ports = [ 33177 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "jb" ];
      };
    };
  };
}
