{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homeServer.containers.stack.nas;
  shareFolder = "${config.homeServer.containers.directory.share}/nas";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${shareFolder} 0755 - - -"
    ];

    # Enable hevc support
    # https://github.com/9001/copyparty/blob/hovudstraum/docs/bad-codecs.md
    services.podman.builds = {
      "copyparty" = {
        file =
          let
            containerFile = pkgs.writeTextFile {
              name = "Containerfile";
              text = ''
                FROM docker.io/copyparty/ac:latest
                RUN apk del ffmpeg \
                  ffmpeg-libavcodec \
                  ffmpeg-libavdevice \
                  ffmpeg-libavfilter \
                  ffmpeg-libavformat \
                  ffmpeg-libavutil \
                  ffmpeg-libs \
                  ffmpeg-libswresample \
                  ffmpeg-libswscale \
                  && apk add --no-cache py3-pip ffmpeg vips vips-jxl vips-heif vips-poppler vips-magick \
                  && rm -f /usr/lib/python3*/EXTERNALLY-MANAGED \
                  && python3 -m pip install pyvips
              '';
            };
          in
          "${containerFile}";
      };
    };

    # https://github.com/9001/copyparty
    services.podman.containers.copyparty = {
      image = "copyparty.build";

      network = [
        "nas"
      ];
      ports = [ "3923:3923" ];
      userNS = "keep-id";
      volumes = [
        "${shareFolder}:/w"
        "${config.sops.templates."containers/copyparty".path}:/cfg/copyparty.conf"
      ];
    };

    sops = {
      secrets = {
        "containers/copyparty/admin" = { };
      };
      templates = {
        "containers/copyparty".content = ''
          [global]
            e2dsa  # enable file indexing and filesystem scanning
            e2ts   # enable multimedia indexing
            ansi   # enable colors in log messages (both in logfiles and stdout)

          [accounts]
            copyparty: ${config.sops.placeholder."containers/copyparty/admin"}

          [/]            # create a volume at "/" (the webroot), which will
            /w           # share /w (the container data volume)
            accs:
              rwmda: copyparty  # the user "copyparty" gets read-write-move-delete-admin
        '';
      };
    };
  };
}
