{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.network;
in
{
  imports = [
    ./pihole.nix
    ./proxy.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.network = { };
  };
}
