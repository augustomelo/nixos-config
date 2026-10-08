{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
in
{
  config = lib.mkIf cfg.enable {
    # https://github.com/qdm12/gluetun
    # https://github.com/qdm12/gluetun-wiki
    services.podman.containers.privoxy = {
      image = "docker.io/qmcgaw/gluetun:v3.41";

      autoUpdate = "registry";
      addCapabilities = [
        "NET_ADMIN"
        "NET_RAW"
      ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      environmentFile = [ "${config.sops.templates."containers/privoxy".path}" ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.qbittorrent.entrypoints" = "websecure";
        "traefik.http.routers.qbittorrent.rule" = "Host(`torrents.jali.foo`)";
        "traefik.http.routers.qbittorrent.service" = "qbittorrent";
        "traefik.http.routers.qbittorrent.tls" = "true";
        "traefik.http.routers.qbittorrent.tls.certresolver" = "le";
        "traefik.http.services.qbittorrent.loadbalancer.server.port" = "8080";
      };
      network = [ 
        "reverse-proxy"
        "servarr"
      ];
      ports = [
        "6881:6881/tcp"
        "6881:6881/udp"
      ];
    };

    sops = {
      secrets = {
        "containers/privoxy/wireguard_addresses" = { };
        "containers/privoxy/wireguard_private_key" = { };
      };
      templates = {
        "containers/privoxy".content = ''
          HTTPPROXY=on
          SERVER_COUNTRIES=Singapore
          TZ=Etc/UTC
          UPDATER_PERIOD=24h
          VPN_SERVICE_PROVIDER=mullvad
          VPN_TYPE=wireguard
          WIREGUARD_ADDRESSES=${config.sops.placeholder."containers/privoxy/wireguard_addresses"}
          WIREGUARD_PRIVATE_KEY=${config.sops.placeholder."containers/privoxy/wireguard_private_key"}
        '';
      };
    };
  };
}
