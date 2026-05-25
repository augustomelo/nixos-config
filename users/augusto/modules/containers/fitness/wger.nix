{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homeServer.containers.stack.fitness;
  storageFolder = "${config.homeServer.containers.directory.storage}/fitness/wger";
  nginxConf = pkgs.writeTextFile {
    name = "nginx.conf";
    text = ''

      upstream wger {
          server wger-web:8000;
      }

      # JSON access log format compatible with the Loki/Alloy parser
      # (same field names as the Caddy parser, so the same dashboard works).
      log_format json_access escape=json
          '{'
              '"ts":"$time_iso8601",'
              '"client_ip":"$remote_addr",'
              '"request_method":"$request_method",'
              '"request_uri":"$request_uri",'
              '"request_proto":"$server_protocol",'
              '"request_host":"$host",'
              '"status":$status,'
              '"size":$body_bytes_sent,'
              '"duration":$request_time,'
              '"user_agent":"$http_user_agent",'
              '"referer":"$http_referer"'
          '}';

      # Universal X-Forwarded-Proto handling for all deployment scenarios
      # - Uses upstream value when behind reverse proxy (Traefik, Caddy, etc.)
      # - Falls back to nginx's scheme for direct connections and port forwarding
      map $http_x_forwarded_proto $final_forwarded_proto {
          default $http_x_forwarded_proto;
          \'\'      $scheme;
      }

      server {

          listen 80;

          access_log /dev/stdout json_access;

          location / {
              proxy_pass http://wger;

              # Standard proxy headers
              proxy_set_header Host $http_host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $final_forwarded_proto;
              proxy_set_header X-Forwarded-Host $http_host;

              # WebSocket support
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";

              proxy_redirect off;
              proxy_http_version 1.1;

              # Timeouts for WebSocket connections
              proxy_read_timeout 86400s;
              proxy_send_timeout 86400s;
          }

          location /static/ {
              alias /wger/static/;

              # Files in the static folder are preprocessed by collectstatic and have a hash
              # in their names, so we can cache longer
              add_header Cache-Control "public, max-age=31536000, immutable" always;
              add_header Vary "Accept-Encoding" always;
          }

          location /media/ {
              alias /wger/media/;
          }

          # Increase max body size to allow for video uploads
          client_max_body_size 100M;
      }
    '';
  };
in
{
  config = lib.mkIf cfg.enable {

    systemd.user.tmpfiles.rules = [
      "f ${storageFolder}/db/database.sqlite 0664 - - -"
    ];

    services.podman.containers = {
      # https://github.com/wger-project/docker
      wger-web = {
        image = "docker.io/wger/server:latest";

        autoUpdate = "registry";
        extraConfig = {
          Unit = {
            After = "podman-wger-cache.service";
            Requires = "podman-wger-cache.service";
            PartOf = "podman-wger-cache.service";
          };
        };
        environmentFile = [ "${config.sops.templates."containers/wger".path}" ];
        extraPodmanArgs = [
          ''--health-cmd="wget --no-verbose --tries=1 --spider http://localhost:8000"''
          "--health-interval=10s"
          "--health-on-failure=stop"
          "--health-retries=5"
          "--health-start-period=300s"
          "--health-timeout=5s"
        ];
        network = [
          "fitness"
        ];
        userNS = "keep-id";
        volumes = [
          "${storageFolder}/db/database.sqlite:/home/wger/src/database.sqlite"
          "static:/home/wger/static"
          "media:/home/wger/media"
        ];
      };

      wger-server = {
        image = "docker.io/nginx:stable";

        autoUpdate = "registry";
        extraConfig = {
          Unit = {
            After = "podman-wger-web.service";
            Requires = "podman-wger-web.service";
            PartOf = "podman-wger-web.service";
          };
        };
        extraPodmanArgs = [
          ''--health-cmd="service nginx status"''
          "--health-interval=10s"
          "--health-on-failure=stop"
          "--health-retries=5"
          "--health-start-period=30s"
          "--health-timeout=5s"
        ];
        ports = [ "9000:80" ];
        network = [
          "fitness"
        ];
        volumes = [
          "${nginxConf}:/etc/nginx/conf.d/default.conf"
          "static:/wger/static:ro"
          "media:/wger/media:ro"
        ];
      };

      wger-cache = {
        image = "docker.io/redis:8";

        autoUpdate = "registry";
        network = [
          "fitness"
        ];
      };

      wger-celery-worker = {
        image = "docker.io/wger/server:latest";

        autoUpdate = "registry";
        exec = "/start-worker";
        extraConfig = {
          Unit = {
            After = "podman-wger-web.service";
            Requires = "podman-wger-web.service";
            PartOf = "podman-wger-web.service";
          };
        };
        environmentFile = [ "${config.sops.templates."containers/wger".path}" ];
        extraPodmanArgs = [
          ''--health-cmd="celery -A wger inspect ping"''
          "--health-interval=10s"
          "--health-on-failure=stop"
          "--health-retries=5"
          "--health-start-period=30s"
          "--health-timeout=5s"
        ];
        network = [
          "fitness"
        ];
        userNS = "keep-id";
        volumes = [
          "${storageFolder}/db/database.sqlite:/home/wger/src/database.sqlite"
          "media:/home/wger/media"
        ];
      };

      wger-celery-beat = {
        image = "docker.io/wger/server:latest";

        autoUpdate = "registry";
        exec = "/start-beat";
        extraConfig = {
          Unit = {
            After = "podman-wger-celery-worker.service";
            Requires = "podman-wger-celery-worker.service";
            PartOf = "podman-wger-celery-worker.service";
          };
        };
        environmentFile = [ "${config.sops.templates."containers/wger".path}" ];
        network = [
          "fitness"
        ];
        userNS = "keep-id";
        volumes = [
          "${storageFolder}/db/database.sqlite:/home/wger/src/database.sqlite"
          "celery-beat:/home/wger/beat/"
        ];
      };
    };

    sops = {
      secrets = {
        "containers/wger/celery_flower_password" = { };
        "containers/wger/db_password" = { };
        "containers/wger/secret_key" = { };
        "containers/wger/signing_key" = { };
      };
      templates = {
        "containers/wger".content = ''
          ACCESS_TOKEN_LIFETIME=10
          ALLOW_GUEST_USERS=False
          ALLOW_REGISTRATION=True
          ALLOW_UPLOAD_VIDEOS=True
          AXES_ENABLED=False
          CACHE_API_EXERCISES_CELERY=True
          CACHE_API_EXERCISES_CELERY_FORCE_UPDATE=True
          CELERY_BACKEND=redis://wger-cache:6379/2
          CELERY_BROKER=redis://wger-cache:6379/2
          CELERY_FLOWER_PASSWORD=${config.sops.placeholder."containers/wger/celery_flower_password"}
          CELERY_WORKER_CONCURRENCY=1
          DJANGO_CACHE_BACKEND=django_redis.cache.RedisCache
          DJANGO_CACHE_CLIENT_CLASS=django_redis.client.DefaultClient
          DJANGO_CACHE_LOCATION=redis://wger-cache:6379/1
          DJANGO_CACHE_TIMEOUT=1296000
          DJANGO_CLEAR_STATIC_FIRST=False
          DJANGO_COLLECTSTATIC_ON_STARTUP=True
          DJANGO_DB_DATABASE=/home/wger/src/database.sqlite
          DJANGO_DB_ENGINE=django.db.backends.sqlite3
          DJANGO_DB_HOST=db
          DJANGO_DB_PASSWORD=${config.sops.placeholder."containers/wger/db_password"}
          DJANGO_DB_PORT=5432
          DJANGO_DB_USER=wger
          DJANGO_DEBUG=False
          DJANGO_PERFORM_MIGRATIONS=True
          DJANGO_STORAGES_STATICFILES_BACKEND=django.contrib.staticfiles.storage.StaticFilesStorage
          DOWNLOAD_INGREDIENTS_FROM=WGER
          EXERCISE_CACHE_TTL=86400
          EXPOSE_PROMETHEUS_METRICS=False
          LOG_LEVEL_PYTHON=INFO
          NUMBER_OF_PROXIES=0
          REFRESH_TOKEN_LIFETIME=2880
          SECRET_KEY=${config.sops.placeholder."containers/wger/secret_key"}
          SIGNING_KEY=${config.sops.placeholder."containers/wger/signing_key"}
          SITE_URL=http://localhost
          SYNC_EXERCISES_CELERY=True
          SYNC_EXERCISES_ON_STARTUP=True
          SYNC_EXERCISE_IMAGES_CELERY=True
          SYNC_EXERCISE_VIDEOS_CELERY=True
          SYNC_INGREDIENTS_CELERY=True
          SYNC_INGREDIENTS_DUMP_URL=https://wger.de/media/ingredients/ingredients.jsonl.gz
          TIME_ZONE=Etc/UTC
          TZ=Etc/UTC
          USE_CELERY=True
          USE_RECAPTCHA=False
          WGER_INSTANCE=https://wger.de
          WGER_PORT=8000
          WGER_USE_GUNICORN=True
        '';
      };
    };
  };
}
