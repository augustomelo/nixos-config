{
  config,
  pkgs,
  ...
}:
{
  services.beszel.agent = {
    enable = true;
    environmentFile = "${config.sops.templates.baeszelAgent.path}";
    extraPath = [ pkgs.intel-gpu-tools ];
    smartmon = {
      enable = true;
      deviceAllow = [
        "/dev/nvme0n1"
      ];
    };
  };

  sops = {
    secrets = {
      "containers/beszelHub/key" = { };
      beszelAgentToken = { };
    };

    templates = {
      baeszelAgent.content = ''
        DOCKER_HOST=unix:///run/podman-socket-proxy/podman.sock
        HUB_URL=http://metrics.jali.foo:8090
        INTEL_GPU_DEVICE=drm:/dev/dri/card0
        KEY="${config.sops.placeholder."containers/beszelHub/key"}"
        LOG_LEVEL=debug
        TOKEN=${config.sops.placeholder.beszelAgentToken}
      '';
    };
  };

  systemd.services = {
    beszel-agent = {
      serviceConfig = {
        AmbientCapabilities = [
          "CAP_PERFMON"
        ];
        CapabilityBoundingSet = [
          "CAP_PERFMON"
        ];
        DeviceAllow = [
          "/dev/dri/card0 rw"
          "/dev/dri/renderD128 rw"
        ];
        SupplementaryGroups = [
          "video"
          "render"
        ];
        SystemCallFilter = [ "perf_event_open" ];
      };
    };
    podman-socket-proxy = {
      enable = true;
      description = "Podman socket proxy for beszel";
      after = [
        "network.target"
        "user@1000.service"
      ];
      requires = [ "user@1000.service" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "user@1000.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:%t/podman-socket-proxy/podman.sock,fork,user=%u,group=podman-socket-proxy,mode=0660 UNIX-CONNECT:/run/user/1000/podman/podman.sock";
        RuntimeDirectory = "podman-socket-proxy";
        Group = "podman-socket-proxy";
        Restart = "always";
        RestartSec = "5";
      };
    };
  };

  users = {
    groups = {
      podman-socket-proxy = { };
    };
    users = {
      augusto = {
        extraGroups = [
          "podman-socket-proxy"
        ];
      };

      beszel-agent = {
        extraGroups = [
          "podman-socket-proxy"
        ];
      };
    };
  };
}
