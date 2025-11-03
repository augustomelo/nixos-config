{
  config,
  ...
}:
{
  imports = [
    ./modules/developerTools
    ./modules/containers
  ];

  systemd.user.tmpfiles.settings = {
    "personal" = {
      rules."${config.home.homeDirectory}/workspace/personal".d = {
        mode = "0755";
        user = "-";
        group = "-";
        age = "-";
      };
      purgeOnChange = false;
    };

    "work" = {
      rules."${config.home.homeDirectory}/workspace/work".d = {
        mode = "0755";
        user = "-";
        group = "-";
        age = "-";
      };
      purgeOnChange = false;
    };
  };

  home.stateVersion = "25.05";
  xdg.enable = true;
}
