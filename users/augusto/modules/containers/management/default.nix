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
    ./beszel.nix
    ./dozzle.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.management = { };
  };
}
