{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
  storageFolder = "${config.homeServer.containers.directory.storage}/media/yamtrack";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${storageFolder}/db 0755 - - -"
    ];

    services.podman.containers = {
      # https://fuzzygrim.github.io/Yamtrack/release/
      yamtrack = {
        image = "ghcr.io/fuzzygrim/yamtrack:latest";

        environmentFile = [ "${config.sops.templates."containers/yamtrack".path}" ];
        group = 0;
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.yamtrack.entrypoints" = "websecure";
          "traefik.http.routers.yamtrack.rule" = "Host(`tracking.jali.foo`)";
          "traefik.http.routers.yamtrack.tls" = "true";
          "traefik.http.routers.yamtrack.tls.certresolver" = "le";
        };
        network = [
          "media"
          "reverse-proxy"
        ];
        user = 0;
        userNS = "keep-id:uid=1000,gid=100";
        volumes = [
          "${storageFolder}/db:/yamtrack/db"
        ];
      };

      yamtrack-cache = {
        image = "docker.io/redis:8-alpine";

        network = [
          "media"
        ];
      };
    };

    sops = {
      secrets = {
        "containers/yamtrack/secret" = { };
      };
      templates = {
        "containers/yamtrack".content = ''
          PGID=100
          PUID=1000
          REDIS_URL=redis://yamtrack-cache:6379
          SECRET=${config.sops.placeholder."containers/yamtrack/secret"}
          TZ=Etc/UTC
          URLS=https://tracking.jali.foo
        '';
      };
    };
  };
}
