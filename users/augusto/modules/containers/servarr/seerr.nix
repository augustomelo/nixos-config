{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
  configFolder = "${config.homeServer.containers.directory.config}/servarr/seerr";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
    ];

    # https://github.com/seerr-team/seerr
    services.podman.containers.seerr = {
      image = "ghcr.io/seerr-team/seerr:latest";

      autoUpdate = "registry";
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.seerr.entrypoints" = "websecure";
        "traefik.http.routers.seerr.rule" = "Host(`requests.jali.foo`)";
        "traefik.http.routers.seerr.tls" = "true";
        "traefik.http.routers.seerr.tls.certresolver" = "le";
      };
      network = [
        "reverse-proxy"
        "servarr"
      ];
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/app/config"
      ];
    };
  };
}
