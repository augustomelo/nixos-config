{
  config,
  pkgs,
  ...
}:
let
  sambaConfig = pkgs.writeTextFile {
    name = "smb.conf";
    text = ''
      [global]
        server string = samba
        idmap config * : range = 3000-7999
        security = user
        server min protocol = SMB2
        smb ports = 4445

        # disable printing services
        load printers = no
        printing = bsd
        printcap name = /dev/null
        disable spoolss = yes

      [Data]
        path = /storage
        comment = Shared
        valid users = @smb
        browseable = yes
        writable = yes
        read only = no
        force user = root
        force group = root
    '';
  };
in
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
      ports = [ "4445:4445" ];
      volumes = [
        "/home/jb/home-server/containers/nas/storage/samba:/storage"
        "${sambaConfig}:/etc/samba/smb.conf"
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
