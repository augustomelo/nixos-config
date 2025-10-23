{
  lib,
  config,
  ...
}:
let
  cfg = config.home-server.containers.stack.nas;
  shareFolder = "${config.home-server.containers.directory.share}/nas";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${shareFolder} 0755 - - -"
    ];

    # https://github.com/dockur/samba/
    services.podman.containers.samba = {
      image = "docker.io/dockurr/samba:latest";

      environmentFile = [ "${config.sops.templates."containers/samba".path}" ];
      network = [
        "nas"
      ];
      ports = [ "4445:445" ];
      volumes = [
        "${shareFolder}:/storage"
      ];
    };

    sops = {
      secrets = {
        "containers/samba/password" = { };
      };
      templates = {
        "containers/samba".content = ''
          GID=100
          UID=1000
          USER=transfer
          PASS=${config.sops.placeholder."containers/samba/password"}
        '';
      };
    };
  };
}
