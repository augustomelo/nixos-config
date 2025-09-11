{
  ...
}:
{
  systemd.user.tmpfiles.rules = [
    "d /home/jb/home-server/containers/media/config/jellyfin 0755 - - -"
    "d /home/jb/home-server/containers/shared/media/movies 0755 - - -"
    "d /home/jb/home-server/containers/shared/media/tv 0755 - - -"
  ];

  services.podman.networks.media = { };
  services.podman.containers = {
    # https://docs.linuxserver.io/images/docker-jellyfin
    jellyfin = {
      image = "docker.io/linuxserver/jellyfin:latest";

      devices = [ "/dev/dri:/dev/dri" ];
      environment = {
        TZ = "Etc/UTC";
      };
      network = [
        "media"
        "servarr"
      ];
      ports = [ "8096:8096" ];
      user = "jb";
      userNS = "keep-id";
      volumes = [
        "/home/jb/home-server/containers/media/config/jellyfin:/config"
        "/home/jb/home-server/containers/shared/media/movies:/data/movies"
        "/home/jb/home-server/containers/shared/media/tv:/data/tvshows"
      ];
    };
  };
}
