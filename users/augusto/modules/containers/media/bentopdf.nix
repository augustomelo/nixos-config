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
        image = "docker.io/bentopdf/bentopdf:latest";

        ports = [ "3003:8080" ];
        network = [
          "media"
        ];
        userNS = "keep-id";
      };
    };
  };
}
