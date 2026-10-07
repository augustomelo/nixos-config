{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
  configFolder = "${config.homeServer.containers.directory.config}/media/audiobookshelf";
  storageFolder = "${config.homeServer.containers.directory.storage}/media/audiobookshelf";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
      "d ${storageFolder}/audiobooks 0755 - - -"
      "d ${storageFolder}/podcasts 0755 - - -"
      "d ${storageFolder}/metadata 0755 - - -"
    ];

    # https://www.audiobookshelf.org/docs/
    services.podman.containers.audiobookshelf = {
      image = "ghcr.io/advplyr/audiobookshelf:latest";

      autoUpdate = "registry";
      environment = {
        TZ = "Etc/UTC";
        PORT = "8080";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.audiobookshelf.entrypoints" = "websecure";
        "traefik.http.routers.audiobookshelf.rule" = "Host(`audiobooks.jali.foo`)";
        "traefik.http.routers.audiobookshelf.tls" = "true";
        "traefik.http.routers.audiobookshelf.tls.certresolver" = "le";
        "traefik.http.services.audiobookshelf.loadbalancer.server.port" = "8080";
      };
      network = [
        "media"
        "reverse-proxy"
      ];
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
        "${storageFolder}/audiobooks:/audiobooks"
        "${storageFolder}/podcasts:/podcasts"
        "${storageFolder}/metadata:/metadata"
      ];
    };
  };
}
