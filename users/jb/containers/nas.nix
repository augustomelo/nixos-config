{
  config,
  ...
}:
{
  systemd.user.tmpfiles.rules = [
    "d /home/jb/home-server/containers/nas/storage/samba 0755 - - -"
  ];

  services.podman.networks.nas = { };

  services.podman.containers = {
    # https://github.com/dockur/samba/
    samba = {
      image = "docker.io/dockurr/samba:latest";

      environmentFile = [ "${config.sops.templates."containers/samba".path}" ];
      network = [
        "nas"
      ];
      ports = [ "4445:445" ];
      volumes = [
        "/home/jb/home-server/containers/nas/storage/samba:/storage"
      ];
    };
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
}
