{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.fitness;
  storageFolder = "${config.homeServer.containers.directory.storage}/fitness/opengym";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${storageFolder} 0755 - - -"
    ];

    # https://opengym.ch/docs.html#selfhost
    services.podman.containers.opengym-api = {
      image = "ghcr.io/duartesantos8/opengym-api:latest";

      autoUpdate = "registry";
      environment = {
        ALLOW_GUEST = 0;
        COACH_DISABLED = "1";
        DATA_DIR = "/data";
        FIRST_USER_ADMIN = 1;
        INVITE_ONLY = 1;
        ORIGIN = "https://fitness.jali.foo";
        PORT = 3000;
        RP_ID = "fitness.jali.foo";
        RP_NAME = "openGym";
      };
      network = [
        "fitness"
      ];
      volumes = [
        "${storageFolder}:/data"
      ];
    };

    # https://opengym.ch/docs.html#selfhost
    services.podman.containers.opengym-web = {
      image = "ghcr.io/duartesantos8/opengym-web:latest";

      autoUpdate = "registry";
      environment = {
        BACKEND = "opengym-api";
        PORT = 3000;
        NGINX_PORT = 9090;
        RESOLVER = "10.89.6.1 10.89.5.1";
      };
      extraConfig = {
        Unit = {
          After = "podman-opengym-api.service";
          Requires = "podman-opengym-api.service";
          PartOf = "podman-opengym-api.service";
        };
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.opengym.entrypoints" = "websecure";
        "traefik.http.routers.opengym.rule" = "Host(`fitness.jali.foo`)";
        "traefik.http.routers.opengym.service" = "opengym-nginx";
        "traefik.http.routers.opengym.tls" = "true";
        "traefik.http.routers.opengym.tls.certresolver" = "le";
        "traefik.http.services.opengym-nginx.loadbalancer.server.port" = "9090";
      };
      network = [
        "fitness"
        "reverse-proxy"
      ];
    };
  };
}
