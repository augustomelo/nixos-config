{
  config,
  ...
}:
{
  imports = [
    ./modules/developerTools
    ./modules/containers
  ];

  systemd.user.tmpfiles.rules = [
    "d ${config.home.homeDirectory}/workspace/personal 0755 - - -"
    "d ${config.home.homeDirectory}/workspace/work 0755 - - -"
  ];

  home.stateVersion = "25.05";
  xdg.enable = true;
}
