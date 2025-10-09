{
  config,
  pkgs,
  ...
}:
{
  systemd.user.tmpfiles.rules = [
    "d /home/jb/home-server/containers/media/config/immich 0755 - - -"
    "d /home/jb/home-server/containers/media/config/jellyfin 0755 - - -"
    "d /home/jb/home-server/containers/media/storage/immich-database 0755 - - -"
    "d /home/jb/home-server/containers/media/storage/immich-server 0755 - - -"
    "d /home/jb/home-server/containers/media/storage/paperless-ngx-server/consume 0755 - - -"
    "d /home/jb/home-server/containers/media/storage/paperless-ngx-server/data 0755 - - -"
    "d /home/jb/home-server/containers/media/storage/paperless-ngx-server/export 0755 - - -"
    "d /home/jb/home-server/containers/media/storage/paperless-ngx-server/media 0755 - - -"
    "d /home/jb/home-server/containers/shared/media/movies 0755 - - -"
    "d /home/jb/home-server/containers/shared/media/tv 0755 - - -"
  ];

  services.podman.networks.media = { };

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
    # https://immich.app/docs/overview/welcome
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:v2.0.1";

      devices = [ "/dev/dri:/dev/dri" ];
      environmentFile = [ "${config.sops.templates."containers/immich-server".path}" ];
      extraConfig = {
        Unit = {
          After = "podman-immich-cache.service podman-immich-database.service";
          Requires = "podman-immich-cache.service podman-immich-database.service";
          PartOf = "podman-immich-cache.service podman-immich-database.service";
        };
      };
      network = [
        "media"
      ];
      ports = [ "2283:2283" ];
      volumes = [
        "/home/jb/home-server/containers/media/config/immich:/config"
        "/home/jb/home-server/containers/media/storage/immich-server:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    # https://immich.app/docs/overview/welcome
    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:v2.0.1";

      devices = [ "/dev/dri:/dev/dri" ];
      environment = {
        TZ = "Etc/UTC";
      };
      network = [
        "media"
      ];
      volumes = [
        "/dev/bus/usb:/dev/bus/usb"
        "model-cache:/cache"
      ];
    };

    # https://immich.app/docs/overview/welcome
    immich-cache = {
      image = "docker.io/valkey/valkey:8-bookworm@sha256:fea8b3e67b15729d4bb70589eb03367bab9ad1ee89c876f54327fc7c6e618571";

      # Container.HealthCmd redis-cli ping || exit 1

      devices = [
        "/dev/bus/usb:/dev/bus/usb"
        "/dev/dri:/dev/dri"
      ];
      environment = {
        TZ = "Etc/UTC";
      };
      extraConfig = {
        Container = {
          HealthCmd = "redis-cli ping || exit 1";
        };
      };
      network = [
        "media"
      ];
      volumes = [
        "/dev/bus/usb:/dev/bus/usb"
        "model-cache:/cache"
      ];
    };

    # https://immich.app/docs/overview/welcome
    immich-database = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:41eacbe83eca995561fe43814fd4891e16e39632806253848efaf04d3c8a8b84";

      devices = [ "/dev/dri:/dev/dri" ];
      environmentFile = [ "${config.sops.templates."containers/immich-database".path}" ];
      extraConfig = {
        Container = {
          ShmSize = "128mb";
        };
      };
      network = [
        "media"
      ];
      user = "jb";
      userNS = "keep-id";
      volumes = [
        "/home/jb/home-server/containers/media/storage/immich-database:/var/lib/postgresql/data"
      ];
    };

    # https://docs.linuxserver.io/images/docker-jellyfin
    jellyfin = {
      image = "docker.io/linuxserver/jellyfin:latest";

      devices = [ "/dev/dri:/dev/dri" ];
      environment = {
        TZ = "Etc/UTC";
      };
      network = [
        "media"
        "servarr"
      ];
      ports = [ "8096:8096" ];
      user = "jb";
      userNS = "keep-id";
      volumes = [
        "/home/jb/home-server/containers/media/config/jellyfin:/config"
        "/home/jb/home-server/containers/shared/media/movies:/data/movies"
        "/home/jb/home-server/containers/shared/media/tv:/data/tvshows"
      ];
    };

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
        "/home/jb/home-server/containers/media/storage/paperless-ngx-server/consume:/usr/src/paperless/consume"
        "/home/jb/home-server/containers/media/storage/paperless-ngx-server/data:/usr/src/paperless/data"
        "/home/jb/home-server/containers/media/storage/paperless-ngx-server/export:/usr/src/paperless/export"
        "/home/jb/home-server/containers/media/storage/paperless-ngx-server/media:/usr/src/paperless/media"
      ];
    };
  };

  sops = {
    secrets = {
      "containers/immich/postgres_password" = { };
    };
    templates = {
      "containers/immich-server".content = ''
        TZ=Etc/UTC
        DB_HOSTNAME=immich-database
        DB_PASSWORD=${config.sops.placeholder."containers/immich/postgres_password"}
        REDIS_HOSTNAME=immich-cache
      '';

      "containers/immich-database".content = ''
        TZ=Etc/UTC
        POSTGRES_PASSWORD=${config.sops.placeholder."containers/immich/postgres_password"}
        POSTGRES_USER=postgres
        POSTGRES_DB=immich
        POSTGRES_INITDB_ARGS=--data-checksums
      '';
    };
  };
}
