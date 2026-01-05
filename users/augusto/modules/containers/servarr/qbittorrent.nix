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
        X-Container = {
          HealthCmd = "curl -s http://localhost:8080/api/v2/transfer/info | jq -e '.connection_status == \"connected\" or .connection_status == \"firewalled\"' || exit 1";
          HealthInterval = "30s";
          HealthOnFailure = "stop";
          HealthRetries = "3";
          HealthStartPeriod = "60s";
          HealthTimeout = "10s";
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
