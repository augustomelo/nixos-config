{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.nas;
in
{
  imports = [
    ./samba.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.nas = { };
  };
}
