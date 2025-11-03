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
    systemd.user.tmpfiles.settings = {
      "audiobookshelf-config" = {
        rules."${configFolder}".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "audiobookshelf-storage-audiobooks" = {
        rules."${storageFolder}/audiobooks".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "audiobookshelf-storage-podcasts" = {
        rules."${storageFolder}/podcasts".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "audiobookshelf-storage-metadata" = {
        rules."${storageFolder}/metadata".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };
    };

    # https://www.audiobookshelf.org/docs/
    services.podman.containers.audiobookshelf = {
      image = "ghcr.io/advplyr/audiobookshelf:latest";

      autoUpdate = "registry";
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
