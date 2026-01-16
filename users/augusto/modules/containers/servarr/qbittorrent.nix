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
      "d ${configFolder} 0755 - - -"
      "d ${storageFolder} 0755 - - -"
    ];

    # https://docs.linuxserver.io/images/docker-qbittorrent
    services.podman.containers.qbittorrent = {
      image = "docker.io/linuxserver/qbittorrent:libtorrentv1";

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
      extraPodmanArgs = [
        ''--health-cmd="curl -s http://localhost:8080/api/v2/transfer/info | jq -e '.connection_status == \"connected\"' || exit 1"''
        "--health-interval=30s"
        "--health-on-failure=stop"
        "--health-retries=3"
        "--health-start-period=60s"
        "--health-timeout=10s"
      ];
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
