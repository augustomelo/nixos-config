{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
  configFolder = "${config.homeServer.containers.directory.config}/servarr/jellyseerr";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
    ];

    # https://github.com/Fallenbagel/jellyseerr
    services.podman.containers.jellyseerr = {
      image = "docker.io/fallenbagel/jellyseerr:2.7.3";

      network = [ "servarr" ];
      ports = [ "5055:5055" ];
      volumes = [
        "${configFolder}:/app/config"
      ];
    };
  };
}
