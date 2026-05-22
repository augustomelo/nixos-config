{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.management;
in
{
  imports = [
    ./dozzle.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.management = { };
  };
}
