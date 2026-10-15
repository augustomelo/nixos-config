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
    ./privoxy.nix
    ./profilarr.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./seerr.nix
    ./sonarr.nix
  ];

  config = lib.mkIf cfg.enable {
    services.podman.networks.servarr = { };
  };
}
