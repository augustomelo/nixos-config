{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
  configFolder = "${config.homeServer.containers.directory.config}/servarr/radarr";
  shareFolder = "${config.homeServer.containers.directory.share}/media";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.settings = {
      "radarr-config" = {
        rules."${configFolder}".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "radarr-movies" = {
        rules."${shareFolder}/movies".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };
    };

    # https://docs.linuxserver.io/images/docker-radarr
    services.podman.containers.radarr = {
      image = "docker.io/linuxserver/radarr:latest";

      autoUpdate = "registry";
      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
      ports = [ "7878:7878" ];
      user = "augusto";
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
        "${config.homeServer.containers.directory.storage}/servarr/qbittorrent:/downloads"
        "${shareFolder}/movies:/movies"
      ];
    };
  };
}
