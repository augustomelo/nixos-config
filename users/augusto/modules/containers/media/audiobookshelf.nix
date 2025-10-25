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

      environment = {
        TZ = "Etc/UTC";
        PORT = "8888";
      };
      network = [
        "media"
      ];
      ports = [ "8888:8888" ];
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
