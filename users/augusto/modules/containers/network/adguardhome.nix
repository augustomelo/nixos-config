{
  config,
  lib,
  ...
}:
let
  cfg = config.homeServer.containers.stack.network;
  configFolder = "${config.homeServer.containers.directory.config}/network/adguardhome";
  stateFolder = "${config.homeServer.containers.directory.state}/network/adguardhome";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
      "d ${stateFolder} 0755 - - -"
    ];

    # https://github.com/AdguardTeam/AdGuardHome/wiki
    services.podman.containers.adguardhome = {
      image = "docker.io/adguard/adguardhome:latest";

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.adguardhome.entrypoints" = "websecure";
        "traefik.http.routers.adguardhome.rule" = "Host(`dns.jali.foo`)";
        "traefik.http.routers.adguardhome.service" = "adguardhome-admin-panel";
        "traefik.http.routers.adguardhome.tls" = "true";
        "traefik.http.routers.adguardhome.tls.certresolver" = "le";
        "traefik.http.services.adguardhome-admin-panel.loadbalancer.server.port" = "80";

        "traefik.http.middlewares.adguardhome-setup-strip-prefix.stripprefix.prefixes" = "/setup";
        "traefik.http.routers.adguardhome-setup.entrypoints" = "websecure";
        "traefik.http.routers.adguardhome-setup.middlewares" = "adguardhome-setup-strip-prefix";
        "traefik.http.routers.adguardhome-setup.rule" = "Host(`dns.jali.foo`) && PathPrefix(`/setup`)";
        "traefik.http.routers.adguardhome-setup.service" = "adguardhome-setup-panel";
        "traefik.http.routers.adguardhome-setup.tls" = "true";
        "traefik.http.routers.adguardhome-setup.tls.certresolver" = "le";
        "traefik.http.services.adguardhome-setup-panel.loadbalancer.server.port" = "3000";
      };

      network = [
        "network"
        "reverse-proxy"
      ];
      ports = [
        "5454:53/tcp"
        "5454:53/udp"
      ];
      volumes = [
        "${configFolder}:/opt/adguardhome/conf"
        "${stateFolder}:/opt/adguardhome/work"
      ];
    };
  };
}
