{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.network;
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
