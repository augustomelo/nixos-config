{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
in
{
  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      # https://github.com/alam00000/bentopdf
      bentopdf = {
        image = "docker.io/bentopdf/bentopdf-simple:latest";

        labels = {
          "traefik.enable"="true" ;
          "traefik.http.routers.bentopdf.entrypoints"="websecure";
          "traefik.http.routers.bentopdf.rule"="Host(`pdf.jali.foo`)";
          "traefik.http.routers.bentopdf.tls"="true";
          "traefik.http.routers.bentopdf.tls.certresolver"="le";
        };
        network = [
          "media"
          "reverse-proxy"
        ];
        userNS = "keep-id";
      };
    };
  };
}
