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
    systemd.user.tmpfiles.settings = {
      "jellyseerr-config" = {
        rules."${configFolder}".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };
    };

    # https://github.com/Fallenbagel/jellyseerr
    services.podman.containers.jellyseerr = {
      image = "docker.io/fallenbagel/jellyseerr:latest";

      autoUpdate = "registry";
      network = [ "servarr" ];
      ports = [ "5055:5055" ];
      volumes = [
        "${configFolder}:/app/config"
      ];
    };
  };
}
