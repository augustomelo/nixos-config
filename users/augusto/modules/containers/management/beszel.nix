{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.management;
  storageFolder = "${config.homeServer.containers.directory.storage}/management/beszel";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${storageFolder}/hub 0755 - - -"
      "d ${storageFolder}/agent 0755 - - -"
    ];

    services.podman.containers = {
      # https://www.beszel.dev/
      beszel = {
        image = "docker.io/henrygd/beszel:latest";

        autoUpdate = "registry";
        environment = {
          APP_URL = "https://metrics.jali.foo";
        };
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.beszel.entrypoints" = "websecure";
          "traefik.http.routers.beszel.rule" = "Host(`metrics.jali.foo`)";
          "traefik.http.routers.beszel.tls" = "true";
          "traefik.http.routers.beszel.tls.certresolver" = "le";
        };
        network = [
          "management"
          "reverse-proxy"
        ];
        ports = [ "8090:8090" ];
        userNS = "keep-id";
        volumes = [
          "${storageFolder}/hub:/beszel_data"
        ];
      };
    };
  };
}
