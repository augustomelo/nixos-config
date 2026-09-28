{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.reverseProxy;
in
{
  imports = [
    ./traefik.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.reverse-proxy = { };
  };
}
