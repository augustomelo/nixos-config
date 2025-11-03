{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
  cacheFolder = "${config.homeServer.containers.directory.state}/media/jellyfin";
  configFolder = "${config.homeServer.containers.directory.config}/media/jellyfin";
  shareFolder = "${config.homeServer.containers.directory.share}/media";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.settings = {
      "jellyfin-state" = {
        rules."${cacheFolder}".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "jellyfin-config" = {
        rules."${configFolder}".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "jellyfin-share-movies" = {
        rules."${shareFolder}/movies".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "jellyfin-share-tvshows" = {
        rules."${shareFolder}/tvshows".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };
    };

    # https://docs.linuxserver.io/images/docker-jellyfin
    services.podman.containers.jellyfin = {
      image = "docker.io/jellyfin/jellyfin:latest";

      autoUpdate = "registry";
      devices = [ "/dev/dri:/dev/dri" ];
      environment = {
        TZ = "Etc/UTC";
      };
      network = [
        "media"
        "servarr"
      ];
      ports = [ "8096:8096" ];
      user = "augusto";
      userNS = "keep-id";
      volumes = [
        "${cacheFolder}:/cache"
        "${configFolder}:/config"
        "${shareFolder}/movies:/data/movies"
        "${shareFolder}/tvshows:/data/tvshows"
      ];
    };
  };
}
