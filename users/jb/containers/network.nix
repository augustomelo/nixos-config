{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.network;
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d /home/jb/home-server/containers/network/config/pihole 0755 - - -"
    ];

    services.podman.networks.network = { };

    services.podman.containers = {
      # https://github.com/dockur/samba/
      pihole = {
        image = "docker.io/pihole/pihole:2025.08.0";

        addCapabilities = [
          "CHOWN"
          "NET_BIND_SERVICE"
        ];
        environmentFile = [ "${config.sops.templates."containers/pihole".path}" ];
        network = [
          "network"
        ];
        ports = [
          "5353:53/tcp"
          "5353:53/udp"
          "8008:80/tcp"
        ];
        volumes = [
          "/home/jb/home-server/containers/network/config/pihole:/etc/pihole"
        ];
      };

      # https://github.com/qdm12/gluetun
      # https://github.com/qdm12/gluetun-wiki
      proxy = {
        image = "docker.io/qmcgaw/gluetun:v3.40";

        addCapabilities = [ "NET_ADMIN" ];
        devices = [ "/dev/net/tun:/dev/net/tun" ];
        environmentFile = [ "${config.sops.templates."containers/proxy".path}" ];
        network = [ "network" ];
        ports = [ "9999:8888" ];
      };
    };

    sops = {
      secrets = {
        "containers/pihole/webserver_api_password" = { };
        "containers/proxy/wireguard_addresses" = { };
        "containers/proxy/wireguard_private_key" = { };
      };
      templates = {
        "containers/pihole".content = ''
          FTLCONF_DNS_UPSTREAMS=1.1.1.1;9.9.9.9
          FTLCONF_WEBSERVER_API_PASSWORD=${config.sops.placeholder."containers/pihole/webserver_api_password"}
          PIHOLE_UID=1000
          PIHOLE_GID=100
          TZ=UTC
          WEBTHEME=default-dark
        '';
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
