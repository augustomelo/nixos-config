{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.fitness;
in
{
  imports = [
    ./opengym.nix
    ./nutritrace.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.fitness = { };
  };
}
