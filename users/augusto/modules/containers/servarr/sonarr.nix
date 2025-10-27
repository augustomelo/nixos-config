{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
  configFolder = "${config.homeServer.containers.directory.config}/servarr/sonarr";
  shareFolder = "${config.homeServer.containers.directory.share}/media";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} - - -"
      "d ${shareFolder}/movies 0755 - - -"
      "d ${shareFolder}/tvshows 0755 - - -"
    ];

    # https://docs.linuxserver.io/images/docker-sonarr
    services.podman.containers.sonarr = {
      image = "docker.io/linuxserver/sonarr:latest";

      autoUpdate = "registry";
      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
      ports = [ "8989:8989" ];
      user = "augusto";
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
        "${config.homeServer.containers.directory.storage}/servarr/qbittorrent:/downloads"
        "${shareFolder}/tvshows:/data/tvshows"
      ];
    };
  };
}
