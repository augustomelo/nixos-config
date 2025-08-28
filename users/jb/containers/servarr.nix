{ ... }:
{
  systemd.user.tmpfiles.rules = [
    "d /home/jb/home-server/containers/servarr/config/qbittorrent 0755 - - -"
    "d /home/jb/home-server/containers/servarr/storage/qbittorrent 0755 - - -"
  ];

  services.podman.networks.servarr = { };
  services.podman.containers = {
    # https://github.com/qdm12/gluetun
    # https://github.com/qdm12/gluetun-wiki
    privoxy = {
      image = "docker.io/qmcgaw/gluetun:v3.40";

      environment = {
        TZ = "Etc/UTC";
        UPDATER_PERIOD = "24h";
        VPN_SERVICE_PROVIDER = "mullvad";
        VPN_TYPE = "wireguard";
        WIREGUARD_ADDRESSES = "";
        WIREGUARD_PRIVATE_KEY = "";
      };
      addCapabilities = [ "NET_ADMIN" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];
    };

    # https://docs.linuxserver.io/images/docker-qbittorrent
    qbittorrent = {
      image = "docker.io/linuxserver/qbittorrent:latest";

      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
      ports = [ "8080:8080" ];
      user = "jb";
      userNS = "keep-id";
      volumes = [
        "/home/jb/home-server/containers/servarr/config/qbittorrent:/config"
        "/home/jb/home-server/containers/servarr/storage/qbittorrent:/downloads"
      ];
    };
  };
}
