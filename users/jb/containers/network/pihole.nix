{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.network;
  configFolder = "${config.home-server.containers.directory.config}/network/pihole";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
    ];

    # https://docs.pi-hole.net/docker/
    services.podman.containers.pihole = {
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
        "${configFolder}:/etc/pihole"
      ];
    };

    sops = {
      secrets = {
        "containers/pihole/webserver_api_password" = { };
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
      };
    };
  };
}
