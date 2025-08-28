{
  ...
}:
{
  imports = [
    ./containers
  ];

  home = {
    homeDirectory = "/home/jb";
    stateVersion = "25.05";
  };

  sops = {
    age.keyFile = "/etc/nixos/key.txt";
    defaultSopsFile = ../../secrets/home-server.yaml;
    defaultSopsFormat = "yaml";
  };

  systemd.user.services.mbsync.unitConfig.After = [ "sops-nix.service" ];

  xdg.enable = true;

}
