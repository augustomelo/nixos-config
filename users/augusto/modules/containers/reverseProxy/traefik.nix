{
  config,
  lib,
  ...
}:
let
  cfg = config.homeServer.containers.stack.reverseProxy;
  storageFolder = "${config.homeServer.containers.directory.storage}/reverseProxy/traefik";
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.tmpfiles.rules = [
      "f ${storageFolder}/acme.json 0600 - - -"
    ];

    # https://doc.traefik.io/traefik
    services.podman.containers.traefik = {
      image = "docker.io/traefik:latest";

      autoUpdate = "registry";
      environmentFile = [ "${config.sops.templates."containers/traefik.env".path}" ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.middlewares.dashboard-auth.basicAuth.usersFile" = "/etc/traefik/userFile";
        "traefik.http.routers.traefik.entrypoints" = "websecure";
        "traefik.http.routers.traefik.middlewares" = "dashboard-auth";
        "traefik.http.routers.traefik.rule" = "Host(`proxy.jali.foo`)";
        "traefik.http.routers.traefik.service" = "api@internal";
        "traefik.http.routers.traefik.tls" = "true";
        "traefik.http.routers.traefik.tls.certresolver" = "le";
      };
      network = [
        "reverse-proxy"
      ];
      ports = [
        "6443:443"
      ];
      volumes = [
        "/run/user/%U/podman/podman.sock:/var/run/docker.sock:ro"
        "${config.sops.templates."containers/traefik.auth".path}:/etc/traefik/userFile"
        "${config.sops.templates."containers/traefik.yaml".path}:/etc/traefik/traefik.yml:ro"
        "${storageFolder}/acme.json:/letsencrypt/acme.json"
      ];
    };

    sops = {
      secrets = {
        "containers/traefik/hashed_password" = { };
        "containers/traefik/email" = { };
        "containers/traefik/cloudflare_token" = { };
      };
      templates = {
        "containers/traefik.auth".content = ''
          admin:${config.sops.placeholder."containers/traefik/hashed_password"}
        '';
        "containers/traefik.env".content = ''
          CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."containers/traefik/cloudflare_token"}
          CF_DNS_API_TOKEN=${config.sops.placeholder."containers/traefik/cloudflare_token"}
        '';
        "containers/traefik.yaml".content = ''
          api:
            dashboard: true
          certificatesResolvers:
            le:
              acme:
                email: ${config.sops.placeholder."containers/traefik/email"}
                storage: /letsencrypt/acme.json
                dnsChallenge:
                  provider: cloudflare
          entryPoints:
            web:
              http:
                redirections:
                  entrypoint:
                    to: websecure
                    scheme: https
            websecure:
              address: ":443"
          log:
            level: INFO
          providers:
            docker: 
              exposedbydefault: false
              network: reverse-proxy
        '';
      };
    };
  };
}
