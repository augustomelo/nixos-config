{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.servarr;
  configFolder = "${config.homeServer.containers.directory.config}/servarr/qbittorrent";
  storageFolder = "${config.homeServer.containers.directory.storage}/servarr/qbittorrent";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} - - -"
      "d ${storageFolder} - - -"
    ];

    # https://docs.linuxserver.io/images/docker-qbittorrent
    services.podman.containers.qbittorrent = {
      image = "docker.io/linuxserver/qbittorrent:latest";

      autoUpdate = "registry";
      environment = {
        TZ = "Etc/UTC";
      };
      extraConfig = {
        Unit = {
          After = "podman-privoxy.service";
          Requires = "podman-privoxy.service";
          PartOf = "podman-privoxy.service";
        };
      };
      network = [ "container:privoxy" ];
      user = "augusto";
      userNS = "keep-id";
      volumes = [
        "${configFolder}:/config"
        "${storageFolder}:/downloads"
      ];
    };
  };
}
