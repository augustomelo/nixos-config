{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
  storageFolder = "${config.homeServer.containers.directory.storage}/media/papra";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${storageFolder}/db 0755 - - -"
      "d ${storageFolder}/documents 0755 - - -"
    ];

    services.podman.containers = {
      # https://github.com/papra-hq/papra
      papra = {
        image = "ghcr.io/papra-hq/papra:latest-root";

        autoUpdate = "registry";
        environmentFile = [ "${config.sops.templates."containers/papra".path}" ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.papra.entrypoints" = "websecure";
          "traefik.http.routers.papra.rule" = "Host(`docs.jali.foo`)";
          "traefik.http.routers.papra.tls" = "true";
          "traefik.http.routers.papra.tls.certresolver" = "le";
        };
        network = [
          "media"
          "reverse-proxy"
        ];
        userNS = "keep-id";
        volumes = [
          "${storageFolder}:/app/app-data"
        ];
      };
    };

    sops = {
      secrets = {
        "containers/papra/auth_secret" = { };
      };
      templates = {
        "containers/papra".content = ''
          APP_BASE_URL=https://docs.jali.foo
          AUTH_SECRET=${config.sops.placeholder."containers/papra/auth_secret"}
        '';
      };
    };
  };
}
