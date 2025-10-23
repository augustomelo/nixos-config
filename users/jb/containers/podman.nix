{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.home-server.containers.enable {
    services.podman = {
      enable = true;
      enableTypeChecks = true;
    };
  };
}
