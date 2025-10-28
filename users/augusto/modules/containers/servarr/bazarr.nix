{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
  configFolder = "${config.homeServer.containers.directory.config}/servarr/bazarr";
  shareFolder = "${config.homeServer.containers.directory.share}/media";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
    ];

    # https://docs.linuxserver.io/images/docker-bazarr
    services.podman.containers.bazarr = {
      image = "docker.io/linuxserver/bazarr:latest";

      autoUpdate = "registry";
      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
      ports = [ "6767:6767" ];
      user = "augusto";
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
        "${shareFolder}/movies:/movies"
        "${shareFolder}/tvshows:/tv"
      ];
    };
  };
}
