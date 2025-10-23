{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.servarr;
  configFolder = "${config.home-server.containers.directory.config}/servarr/prowlarr";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} - - -"
    ];

    # https://docs.linuxserver.io/images/docker-prowlarr
    services.podman.containers.prowlarr = {
      image = "docker.io/linuxserver/prowlarr:latest";

      environment = {
        TZ = "Etc/UTC";
      };
      network = [ "servarr" ];
      ports = [ "9696:9696" ];
      user = "jb";
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
      ];
    };
  };
}
