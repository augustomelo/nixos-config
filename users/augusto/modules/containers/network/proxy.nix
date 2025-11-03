{
  config,
  lib,
  ...
}:
let
  cfg = config.homeServer.containers.stack.network;
  configFolder = "${config.homeServer.containers.directory.config}/network/gluetun";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.settings = {
      "privoxy-config" = {
        rules.${configFolder}.d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };
    };

    # https://github.com/qdm12/gluetun
    # https://github.com/qdm12/gluetun-wiki
    services.podman.containers.proxy = {
      image = "docker.io/qmcgaw/gluetun:v3.40";

      addCapabilities = [ "NET_ADMIN" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      environmentFile = [ "${config.sops.templates."containers/proxy".path}" ];
      network = [ "network" ];
      ports = [ "9999:8888" ];
    };

    sops = {
      secrets = {
        "containers/proxy/wireguard_addresses" = { };
        "containers/proxy/wireguard_private_key" = { };
      };
      templates = {
        "containers/proxy".content = ''
          HTTPPROXY=on
          SERVER_COUNTRIES=Brazil
          TZ=Etc/UTC
          UPDATER_PERIOD=24h
          VPN_SERVICE_PROVIDER=mullvad
          VPN_TYPE=wireguard
          WIREGUARD_ADDRESSES=${config.sops.placeholder."containers/proxy/wireguard_addresses"}
          WIREGUARD_PRIVATE_KEY=${config.sops.placeholder."containers/proxy/wireguard_private_key"}
        '';
      };
    };
  };
}
