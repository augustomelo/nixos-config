{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.media;
  configFolder = "${config.home-server.containers.directory.storage}/media/jellyfin";
  shareFolder = "${config.home-server.containers.directory.share}/media";
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

      devices = [ "/dev/dri:/dev/dri" ];
      environment = {
        TZ = "Etc/UTC";
      };
      network = [
        "media"
        "servarr"
      ];
      ports = [ "8096:8096" ];
      user = "jb";
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
        "${shareFolder}/movies:/data/movies"
        "${shareFolder}/tvshows:/data/tvshows"
      ];
    };
  };
}
