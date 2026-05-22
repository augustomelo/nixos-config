{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.management;
in
{
  config = lib.mkIf cfg.enable {
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
        ports = [ "9090:8080" ];
        network = [
          "management"
        ];
        userNS = "keep-id";
        volumes = [
          "/run/user/%U/podman/podman.sock:/var/run/docker.sock:ro"
          "dozzle_data:/data"
        ];
      };
    };
  };
}
