{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.nas;
in
{
  imports = [
    ./samba.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.nas = { };
  };
}
