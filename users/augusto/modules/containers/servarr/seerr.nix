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
      network = [ "servarr" ];
      ports = [ "5055:5055" ];
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/app/config"
      ];
    };
  };
}
