{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.media;
  configFolder = "${config.home-server.containers.directory.config}/media";
  storageFolder = "${config.home-server.containers.directory.storage}/media";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder}/immich-server 0755 - - -"
      "d ${storageFolder}/immich-database 0755 - - -"
      "d ${storageFolder}/immich-server 0755 - - -"
    ];

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
        userNS = "keep-id";
        volumes = [
          "${configFolder}/immich-server:/config"
          "${storageFolder}/immich-server:/data"
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
          "immich-model-cache:/cache"
        ];
      };

      # https://immich.app/docs/overview/welcome
      immich-cache = {
        image = "docker.io/valkey/valkey:8-bookworm@sha256:fea8b3e67b15729d4bb70589eb03367bab9ad1ee89c876f54327fc7c6e618571";

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
          "${storageFolder}/immich-database:/var/lib/postgresql/data"
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
  };
}
