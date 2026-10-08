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
    systemd.user.tmpfiles.rules = [
      "d ${cacheFolder} 0755 - - -"
      "d ${configFolder} 0755 - - -"
      "d ${shareFolder}/movies 0755 - - -"
      "d ${shareFolder}/tvshows 0755 - - -"
    ];

    # https://docs.linuxserver.io/images/docker-jellyfin
    services.podman.containers.jellyfin = {
      image = "docker.io/jellyfin/jellyfin:latest";

      autoUpdate = "registry";
      devices = [ "/dev/dri:/dev/dri" ];
      environment = {
        TZ = "Etc/UTC";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.jellyfin.entrypoints" = "websecure";
        "traefik.http.routers.jellyfin.rule" = "Host(`watch.jali.foo`)";
        "traefik.http.routers.jellyfin.tls" = "true";
        "traefik.http.routers.jellyfin.tls.certresolver" = "le";
      };
      network = [
        "media"
        "reverse-proxy"
        "servarr"
      ];
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
