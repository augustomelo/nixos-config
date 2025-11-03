{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
  shareFolder = "${config.homeServer.containers.directory.share}/nas/paperless-ngx-server";
  storageFolder = "${config.homeServer.containers.directory.storage}/media/paperless-ngx-server";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.settings = {
      "paperless-ngx-share-consume" = {
        rules."${shareFolder}/consume".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "paperless-ngx-share-export" = {
        rules."${shareFolder}/export".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "paperless-ngx-storage-data" = {
        rules."${storageFolder}/data".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };

      "paperless-ngx-storage-media" = {
        rules."${storageFolder}/consume".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };
    };

    services.podman.containers = {
      # https://docs.paperless-ngx.com/setup/#docker
      paperless-ngx-broker = {
        image = "docker.io/library/redis:8";

        network = [
          "media"
        ];
      };

      # https://docs.paperless-ngx.com/setup/#docker
      paperless-ngx-server = {
        image = "ghcr.io/paperless-ngx/paperless-ngx:latest";

        extraConfig = {
          Unit = {
            After = "podman-paperless-ngx-broker.service";
            Requires = "podman-paperless-ngx-broker.service";
            PartOf = "podman-paperless-ngx-broker.service";
          };
        };
        environment = {
          PAPERLESS_OCR_LANGUAGE = "por+eng";
          PAPERLESS_OCR_LANGUAGES = "por";
          PAPERLESS_REDIS = "redis://paperless-ngx-broker:6379";
          PAPERLESS_TIME_ZONE = "Etc/UTC";
          USERMAP_GID = 100;
          USERMAP_UID = 1000;
        };
        network = [
          "media"
        ];
        ports = [ "8000:8000" ];
        volumes = [
          "${shareFolder}/consume:/usr/src/paperless/consume"
          "${shareFolder}/export:/usr/src/paperless/export"
          "${storageFolder}/data:/usr/src/paperless/data"
          "${storageFolder}/media:/usr/src/paperless/media"
        ];
      };
    };
  };
}
