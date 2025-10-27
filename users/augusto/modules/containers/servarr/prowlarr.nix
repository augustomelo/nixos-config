{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
  configFolder = "${config.homeServer.containers.directory.config}/servarr/prowlarr";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} - - -"
    ];

    # https://docs.linuxserver.io/images/docker-prowlarr
    services.podman.containers.prowlarr = {
      image = "docker.io/linuxserver/prowlarr:latest";

      autoUpdate = "registry";
      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
      ports = [ "9696:9696" ];
      user = "augusto";
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
      ];
    };
  };
}
