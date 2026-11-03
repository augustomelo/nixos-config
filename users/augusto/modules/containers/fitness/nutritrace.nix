{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.fitness;
  storageFolder = "${config.homeServer.containers.directory.storage}/fitness/nutritrace";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${storageFolder}/db 0755 - - -"
      "d ${storageFolder}/uploads 0755 - - -"
    ];

    # https://traceapps.github.io/docs/nutritrace/
    services.podman.containers.nutritrace = {
      image = "ghcr.io/traceapps/nutritrace:latest";

      autoUpdate = "registry";
      environmentFile = [ "${config.sops.templates."containers/nutritrace".path}" ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.nutritrace.entrypoints" = "websecure";
        "traefik.http.routers.nutritrace.rule" = "Host(`diet.jali.foo`)";
        "traefik.http.routers.nutritrace.tls" = "true";
        "traefik.http.routers.nutritrace.tls.certresolver" = "le";
        "traefik.http.services.nutritrace.loadbalancer.server.port" = "3001";
      };
      network = [
        "fitness"
        "reverse-proxy"
      ];
      volumes = [
        "${storageFolder}/db:/data/db"
        "${storageFolder}/uploads:/data/uploads"
      ];
    };

    sops = {
      secrets = {
        "containers/nutritrace/jwt_secret" = { };
      };
      templates = {
        "containers/nutritrace".content = ''
          DB_PATH=/data/db/nutritrace.db
          JWT_SECRET=${config.sops.placeholder."containers/nutritrace/jwt_secret"}
          LOG_LEVEL=info
          PUBLIC_URL=https://diet.jali.foo
          UPLOADS_PATH=/data/uploads
        '';
      };
    };
  };
}
