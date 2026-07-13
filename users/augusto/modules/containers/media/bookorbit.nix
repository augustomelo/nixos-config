{
  lib,
  config,
  ...
}:
let
  cfg = config.homeServer.containers.stack.media;
  configFolder = "${config.homeServer.containers.directory.config}/media/bookorbit";
  storageFolder = "${config.homeServer.containers.directory.storage}/media/bookorbit";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "d ${configFolder} 0755 - - -"
      "d ${storageFolder}/library/audiobooks 0755 - - -"
      "d ${storageFolder}/library/books 0755 - - -"
      "d ${storageFolder}/library/comics 0755 - - -"
      "d ${storageFolder}/postgres 0755 - - -"
    ];

    # https://bookorbit.app/what-is-bookorbit.html
    services.podman.containers = {
      bookorbit = {
        image = "ghcr.io/bookorbit/bookorbit:latest";

        autoUpdate = "registry";
        environmentFile = [ "${config.sops.templates."containers/bookorbit".path}" ];
        extraConfig = {
          Unit = {
            After = "podman-bookorbit-database.service";
            Requires = "podman-bookorbit-database.service";
            PartOf = "podman-bookorbit-database.service";
          };
        };
        extraPodmanArgs = [
          ''--health-cmd="node -e \"fetch('http://127.0.0.1:3000/api/v1/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))\""''
          "--health-interval=30s"
          "--health-on-failure=stop"
          "--health-retries=3"
          "--health-start-period=20s"
          "--health-timeout=5s"
        ];
        network = [
          "media"
        ];
        ports = [ "3001:3000" ];
        userNS = "keep-id";
        volumes = [
          "${configFolder}:/data"
          "${storageFolder}/library/audiobooks:/audiobooks"
          "${storageFolder}/library/books:/books"
          "${storageFolder}/library/comics:/comics"
        ];
      };

      bookorbit-database = {
        image = "docker.io/pgvector/pgvector:pg16@sha256:7d400e340efb42f4d8c9c12c6427adb253f726881a9985d2a471bf0eed824dff";

        environmentFile = [ "${config.sops.templates."containers/bookorbit-database".path}" ];
        network = [
          "media"
        ];
        extraPodmanArgs = [
          ''--health-cmd="pg_isready -U "bookorbit" -d "bookorbit""''
          "--health-interval=30s"
          "--health-on-failure=stop"
          "--health-retries=3"
          "--health-start-period=20s"
          "--health-timeout=5s"
        ];
        userNS = "keep-id";
        volumes = [
          "${storageFolder}/postgres:/var/lib/postgresql/data"
        ];
      };
    };

    sops = {
      secrets = {
        "containers/bookorbit/jwt_secret" = { };
        "containers/bookorbit/postgres_password" = { };
        "containers/bookorbit/setup_bootstrap_token" = { };
      };
      templates = {
        "containers/bookorbit".content = ''
          NODE_ENV=production
          PORT=3000
          POSTGRES_HOST=bookorbit-database
          POSTGRES_PORT=5432
          POSTGRES_USER=bookorbit
          POSTGRES_PASSWORD=${config.sops.placeholder."containers/bookorbit/postgres_password"}
          POSTGRES_DB=bookorbit
          JWT_SECRET=${config.sops.placeholder."containers/bookorbit/jwt_secret"}
          SETUP_BOOTSTRAP_TOKEN=${config.sops.placeholder."containers/bookorbit/setup_bootstrap_token"}
          APP_URL=https://bookorbit.example.com
          CLIENT_URL=http://192.168.68.137:3000
          PUID=1000
          PGID=100
          NODE_MAX_OLD_SPACE_SIZE=2048
        '';

        "containers/bookorbit-database".content = ''
          POSTGRES_USER=bookorbit
          POSTGRES_PASSWORD=${config.sops.placeholder."containers/bookorbit/postgres_password"}
          POSTGRES_DB=bookorbit
          PGDATA=/var/lib/postgresql/data/pgdata
        '';
      };
    };
  };
}
