{
  config,
  lib,
  ...
}:
let
  cfg = config.homeServer.containers.stack.network;
  configFolder = "${config.homeServer.containers.directory.config}/network/adguardhome";
  stateFolder = "${config.homeServer.containers.directory.state}/network/adguardhome";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.settings = {
      "adguardhome-config" = {
        rules."${configFolder}".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "adguardhome-state" = {
        rules."${configFolder}".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };
    };

    # https://github.com/AdguardTeam/AdGuardHome/wiki
    services.podman.containers.adguardhome = {
      image = "docker.io/adguard/adguardhome:latest";

      network = [
        "network"
      ];
      ports = [
        "5454:53/tcp"
        "5454:53/udp"
        "8008:80/tcp"
        "3000:3000/tcp"
      ];
      volumes = [
        "${configFolder}:/opt/adguardhome/conf"
        "${stateFolder}:/opt/adguardhome/work"
      ];
    };
  };
}
