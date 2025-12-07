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
    systemd.user.tmpfiles.rules = [
      "d ${shareFolder} 0755 - - -"
    ];

    # https://github.com/9001/copyparty
    services.podman.containers.copyparty = {
      image = "docker.io/copyparty/iv:latest";

      autoUpdate = "registry";
      network = [
        "nas"
      ];
      ports = [ "3923:3923" ];
      userNS = "keep-id";
      volumes = [
        "${shareFolder}:/w"
        "${config.sops.templates."containers/copyparty".path}:/cfg/copyparty.conf"
      ];
    };

    sops = {
      secrets = {
        "containers/copyparty/admin" = { };
      };
      templates = {
        "containers/copyparty".content = ''
          [global]
            e2dsa  # enable file indexing and filesystem scanning
            e2ts   # enable multimedia indexing
            ansi   # enable colors in log messages (both in logfiles and stdout)

          [accounts]
            copyparty: ${config.sops.placeholder."containers/copyparty/admin"}

          [/]            # create a volume at "/" (the webroot), which will
            /w           # share /w (the container data volume)
            accs:
              rwmda: copyparty  # the user "copyparty" gets read-write-move-delete-admin
        '';
      };
    };
  };
}
