{
  config,
  ...
}:
{
  systemd.user.tmpfiles.rules = [
    "d /home/jb/home-server/containers/media/config/immich 0755 - - -"
    "d /home/jb/home-server/containers/media/config/jellyfin 0755 - - -"
    "d /home/jb/home-server/containers/media/storage/immich-database 0755 - - -"
    "d /home/jb/home-server/containers/media/storage/immich-server 0755 - - -"
    "d /home/jb/home-server/containers/shared/media/movies 0755 - - -"
    "d /home/jb/home-server/containers/shared/media/tv 0755 - - -"
  ];

  services.podman.networks.media = { };
  services.podman.containers = {
    # https://immich.app/docs/overview/welcome
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:v1.142.0";

      devices = [ "/dev/dri:/dev/dri" ];
      environment = {
        TZ = "Etc/UTC";
        IMMICH_CONFIG_FILE = "/config";
      };
      extraConfig = {
        Unit = {
          After = "podman-immich-redis.service podman-immich-database.service";
          Requires = "podman-immich-redis.service podman-immich-database.service";
          PartOf = "podman-immich-redis.service podman-immich-database.service";
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
      image = "ghcr.io/immich-app/immich-machine-learning:v1.142.0";

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
    immich-redis = {
      image = "ghcr.io/valkey/valkey:8-bookworm@sha256:fea8b3e67b15729d4bb70589eb03367bab9ad1ee89c876f54327fc7c6e618571";

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
    immich-postgres = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:8d292bdb796aa58bbbaa47fe971c8516f6f57d6a47e7172e62754feb6ed4e7b0";

      devices = [ "/dev/dri:/dev/dri" ];
      environmentFile = [ "${config.sops.templates."containers/immich-database".path}" ];
      extraConfig = {
        Container = {
          ShmSize = "128md";
        };
      };
      network = [
        "media"
      ];
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
  };

  sops = {
    secrets = {
      "containers/immich/postgres_password" = { };
    };
    templates = {
      "containers/immich-database".content = ''
        TZ=Etc/UTC;
        POSTGRES_PASSWORD=${config.sops.placeholder."containers/immich/postgres_password"};
        POSTGRES_USER=postgres;
        POSTGRES_DB=immich;
        POSTGRES_INITDB_ARGS=--data-checksums;
      '';
    };
  };
}
