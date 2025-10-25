{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
in
{

  imports = [
    ./bazarr.nix
    ./flaresolverr.nix
    ./jellyseerr.nix
    ./privoxy.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./sonarr.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.servarr = { };
  };
}
