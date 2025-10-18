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
    systemd.user.tmpfiles.rules = [
      "d /home/jb/home-server/containers/servarr/config/bazaar 0755 - - -"
      "d /home/jb/home-server/containers/servarr/config/jellyseerr - - -"
      "d /home/jb/home-server/containers/servarr/config/prowlarr 0755 - - -"
      "d /home/jb/home-server/containers/servarr/config/qbittorrent 0755 - - -"
      "d /home/jb/home-server/containers/servarr/config/radarr - - -"
      "d /home/jb/home-server/containers/servarr/config/sonarr - - -"
      "d /home/jb/home-server/containers/servarr/storage/qbittorrent 0755 - - -"
      "d /home/jb/home-server/containers/shared/media/movies 0755 - - -"
      "d /home/jb/home-server/containers/shared/media/tv 0755 - - -"
    ];

    services.podman.networks.servarr = { };
    services.podman.containers = {
      # https://docs.linuxserver.io/images/docker-bazarr
      bazarr = {
        image = "docker.io/linuxserver/bazarr:latest";

        environment = {
          TZ = "Etc/UTC";
        };
        network = [ "servarr" ];
        ports = [ "6767:6767" ];
        user = "jb";
        userNS = "keep-id";
        volumes = [
          "/home/jb/home-server/containers/servarr/config/bazaar:/config"
          "/home/jb/home-server/containers/shared/media/movies:/movies"
          "/home/jb/home-server/containers/shared/media/tv:/tv"
        ];
      };

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

      # https://github.com/Fallenbagel/jellyseerr
      jellyseerr = {
        image = "docker.io/fallenbagel/jellyseerr:2.7.3";

        network = [ "servarr" ];
        ports = [ "5055:5055" ];
        volumes = [
          "/home/jb/home-server/containers/servarr/config/jellyseerr:/app/config"
        ];
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

      # https://docs.linuxserver.io/images/docker-radarr
      radarr = {
        image = "docker.io/linuxserver/radarr:latest";

        environment = {
          TZ = "Etc/UTC";
        };
        network = [ "servarr" ];
        ports = [ "7878:7878" ];
        user = "jb";
        userNS = "keep-id";
        volumes = [
          "/home/jb/home-server/containers/servarr/config/radarr:/config"
          "/home/jb/home-server/containers/servarr/storage/qbittorrent:/downloads"
          "/home/jb/home-server/containers/shared/media/movies:/movies"
        ];
      };

      # https://docs.linuxserver.io/images/docker-sonarr
      sonarr = {
        image = "docker.io/linuxserver/sonarr:latest";

        environment = {
          TZ = "Etc/UTC";
        };
        network = [ "servarr" ];
        ports = [ "8989:8989" ];
        user = "jb";
        userNS = "keep-id";
        volumes = [
          "/home/jb/home-server/containers/servarr/config/sonarr:/config"
          "/home/jb/home-server/containers/servarr/storage/qbittorrent:/downloads"
          "/home/jb/home-server/containers/shared/media/tv:/tv"
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
  };
}
