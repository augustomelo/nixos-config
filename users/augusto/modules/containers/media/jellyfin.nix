{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
  configFolder = "${config.homeServer.containers.directory.config}/media/jellyfin";
  shareFolder = "${config.homeServer.containers.directory.share}/media";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
      "d ${shareFolder}/movies 0755 - - -"
      "d ${shareFolder}/tvshows 0755 - - -"
    ];

    # https://docs.linuxserver.io/images/docker-jellyfin
    services.podman.containers.jellyfin = {
      image = "docker.io/linuxserver/jellyfin:latest";

      autoUpdate = "registry";
      devices = [ "/dev/dri:/dev/dri" ];
      environment = {
        PUID = 1000;
        PGID = 100;
        TZ = "Etc/UTC";
      };
      network = [
        "media"
        "servarr"
      ];
      ports = [ "8096:8096" ];
      volumes = [
        "${configFolder}:/config"
        "${shareFolder}/movies:/data/movies"
        "${shareFolder}/tvshows:/data/tvshows"
      ];
    };
  };
}
