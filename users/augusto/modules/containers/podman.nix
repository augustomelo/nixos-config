{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.homeServer.containers.enable {
    services.podman = {
      enable = true;
      enableTypeChecks = true;
    };
  };
}
