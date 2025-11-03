{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.nas;
  shareFolder = "${config.homeServer.containers.directory.share}/nas";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.settings = {
      "samba-share" = {
        rules."${shareFolder}".d = {
          mode = "0755";
          user = "-";
          group = "-";
          age = "-";
        };
        purgeOnChange = false;
      };
    };

    # https://github.com/dockur/samba/
    services.podman.containers.samba = {
      image = "docker.io/dockurr/samba:latest";

      autoUpdate = "registry";
      environmentFile = [ "${config.sops.templates."containers/samba".path}" ];
      extraPodmanArgs = [
        "--uidmap=1000:0"
        "--uidmap=0:1000"
      ];
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
          UID=1000
          USER=samba
          PASS=${config.sops.placeholder."containers/samba/password"}
        '';
      };
    };
  };
}
