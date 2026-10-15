{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
  configFolder = "${config.homeServer.containers.directory.config}/servarr/profilarr";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
    ];

    # https://v2.dictionarry.dev/
    services.podman.containers.profilarr = {
      image = "ghcr.io/dictionarry-hub/profilarr:latest";

      autoUpdate = "registry";
      environment = {
        TZ = "Etc/UTC";
        ORIGIN = "https://profiles.jali.foo";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.profilarr.entrypoints" = "websecure";
        "traefik.http.routers.profilarr.rule" = "Host(`profiles.jali.foo`)";
        "traefik.http.routers.profilarr.tls" = "true";
        "traefik.http.routers.profilarr.tls.certresolver" = "le";
      };
      network = [
        "reverse-proxy"
        "servarr"
      ];
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
      ];
    };
  };
}
