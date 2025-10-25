{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
in
{
  config = lib.mkIf cfg.enable {
    # https://github.com/FlareSolverr/FlareSolverr
    services.podman.containers.flaresolverr = {
      image = "docker.io/flaresolverr/flaresolverr:v3.4.0";

      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
    };
  };
}
