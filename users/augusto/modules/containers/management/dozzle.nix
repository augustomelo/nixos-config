{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.management;
  storageFolder = "${config.homeServer.containers.directory.storage}/management/dozzle";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${storageFolder} 0755 - - -"
    ];

    services.podman.containers = {
      # https://dozzle.dev/guide/podman#quadlet-deployment
      dozzle = {
        image = "ghcr.io/amir20/dozzle:latest";

        autoUpdate = "registry";
        extraPodmanArgs = [
          ''--health-cmd='["/dozzle", "healthcheck"]' ''
          "--health-interval=5s"
          "--health-on-failure=stop"
          "--health-retries=5"
          "--health-start-period=15s"
          "--health-timeout=10s"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.dozzle.entrypoints" = "websecure";
          "traefik.http.routers.dozzle.rule" = "Host(`logs.jali.foo`)";
          "traefik.http.routers.dozzle.tls" = "true";
          "traefik.http.routers.dozzle.tls.certresolver" = "le";
        };
        network = [
          "management"
          "reverse-proxy"
        ];
        userNS = "keep-id";
        volumes = [
          "/run/user/%U/podman/podman.sock:/var/run/docker.sock:ro"
          "${storageFolder}:/data"
        ];
      };
    };
  };
}
