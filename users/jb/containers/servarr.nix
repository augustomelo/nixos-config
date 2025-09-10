{
  config,
  ...
}:
{
  systemd.user.tmpfiles.rules = [
    "d /home/jb/home-server/containers/servarr/config/prowlarr 0755 - - -"
    "d /home/jb/home-server/containers/servarr/config/qbittorrent 0755 - - -"
    "d /home/jb/home-server/containers/servarr/storage/qbittorrent 0755 - - -"
  ];

  services.podman.networks.servarr = { };
  services.podman.containers = {
    # https://github.com/FlareSolverr/FlareSolverr
    flaresolverr = {
      image = "docker.io/flaresolverr/flaresolverr:v3.4.0";

      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
    };

    # https://github.com/qdm12/gluetun
    # https://github.com/qdm12/gluetun-wiki
    privoxy = {
      image = "docker.io/qmcgaw/gluetun:v3.40";

      addCapabilities = [ "NET_ADMIN" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      environmentFile = [ "${config.sops.templates."containers/privoxy".path}" ];
      network = [ "servarr" ];
      ports = [ "8080:8080" ];
    };

    # https://docs.linuxserver.io/images/docker-prowlarr
    prowlarr = {
      image = "docker.io/linuxserver/prowlarr:latest";

      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
      ports = [ "9696:9696" ];
      user = "jb";
      userNS = "keep-id";
      volumes = [
        "/home/jb/home-server/containers/servarr/config/prowlarr:/config"
      ];
    };

    # https://docs.linuxserver.io/images/docker-qbittorrent
    qbittorrent = {
      image = "docker.io/linuxserver/qbittorrent:latest";

      environment = {
        TZ = "Etc/UTC";
      };
      extraConfig = {
        Unit = {
          After = "podman-privoxy.service";
          Requires = "podman-privoxy.service";
          PartOf = "podman-privoxy.service";
        };
      };
      network = [ "container:privoxy" ];
      user = "jb";
      userNS = "keep-id";
      volumes = [
        "/home/jb/home-server/containers/servarr/config/qbittorrent:/config"
        "/home/jb/home-server/containers/servarr/storage/qbittorrent:/downloads"
      ];
    };
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
}
