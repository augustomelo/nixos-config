{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
  shareFolder = "${config.homeServer.containers.directory.share}/nas/paperless-ngx-server";
  storageFolder = "${config.homeServer.containers.directory.storage}/media/paperless-ngx-server";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${shareFolder}/consume 0755 - - -"
      "d ${shareFolder}/export 0755 - - -"
      "d ${storageFolder}/data 0755 - - -"
      "d ${storageFolder}/media 0755 - - -"
    ];

    services.podman.builds.paperless-ngx = {
      file =
        let
          containerFile = pkgs.writeTextFile {
            name = "Containerfile";
            text = ''
              FROM ghcr.io/paperless-ngx/paperless-ngx:latest

              # Workaround to avoid running as root
              # https://github.com/paperless-ngx/paperless-ngx/discussions/4019#discussioncomment-10722684
              RUN apt-get update && apt-get install -y tesseract-ocr-por
            '';
          };
        in
        "${containerFile}";
      tags = [ "localhost/paperless-ngx:latest" ];
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
        image = "paperless-ngx.build";

        extraConfig = {
          Unit = {
            After = "podman-paperless-ngx-broker.service";
            Requires = "podman-paperless-ngx-broker.service";
            PartOf = "podman-paperless-ngx-broker.service";
          };
        };
        environment = {
          PAPERLESS_OCR_LANGUAGE = "por+eng";
          PAPERLESS_REDIS = "redis://paperless-ngx-broker:6379";
          PAPERLESS_TIME_ZONE = "Etc/UTC";
        };
        network = [
          "media"
        ];
        ports = [ "8000:8000" ];
        userNS = "keep-id";
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
