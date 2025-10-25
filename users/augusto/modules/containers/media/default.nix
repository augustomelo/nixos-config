{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
in
{
  imports = [
    ./audiobookshelf.nix
    ./immich.nix
    ./jellyfin.nix
    ./paperless-ngx.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.media = { };
  };
}
