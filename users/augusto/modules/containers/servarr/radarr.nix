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
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} - - -"
      "d ${shareFolder}/movies 0755 - - -"
      "d ${shareFolder}/tvshows 0755 - - -"
    ];

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
