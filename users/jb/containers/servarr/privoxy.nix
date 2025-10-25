{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.servarr;
in
{
  config = lib.mkIf cfg.enable {
    # https://github.com/qdm12/gluetun
    # https://github.com/qdm12/gluetun-wiki
    services.podman.containers.privoxy = {
      image = "docker.io/qmcgaw/gluetun:v3.40";

      addCapabilities = [ "NET_ADMIN" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      environmentFile = [ "${config.sops.templates."containers/privoxy".path}" ];
      network = [ "servarr" ];
      ports = [ "8080:8080" ];
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
