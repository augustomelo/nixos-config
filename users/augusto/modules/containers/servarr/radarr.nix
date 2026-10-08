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
      "d ${configFolder} 0755 - - -"
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
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.radarr.entrypoints" = "websecure";
        "traefik.http.routers.radarr.rule" = "Host(`movies.jali.foo`)";
        "traefik.http.routers.radarr.tls" = "true";
        "traefik.http.routers.radarr.tls.certresolver" = "le";
      };
      network = [
        "reverse-proxy"
        "servarr"
      ];
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
