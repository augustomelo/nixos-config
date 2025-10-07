{ pkgs, lib, ... }:
{
  programs = {
    ssh.startAgent = true;
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  boot.binfmt = {
    emulatedSystems = [ "x86_64-linux" ];
    preferStaticEmulators = true;
  };

  nixpkgs.overlays = [
    (final: previous: {
      # https://github.com/NixOS/nixpkgs/issues/392673
      # aarch64-unknown-linux-musl-ld: (.text+0x484): warning: too many GOT entries for -fpic, please recompile with -fPIC
      nettle = previous.nettle.overrideAttrs (
        lib.optionalAttrs final.stdenv.hostPlatform.isStatic {
          CCPIC = "-fPIC";
        }
      );
    })
    # https://github.com/NixOS/nixpkgs/issues/366902
    (final: prev: {
      qemu-user = prev.qemu-user.overrideAttrs (
        old:
        lib.optionalAttrs final.stdenv.hostPlatform.isStatic {
          configureFlags = old.configureFlags ++ [ "--disable-pie" ];
        }
      );
    })
  ];

  users = {
    mutableUsers = false;
    users.augusto = {
      home = "/home/augusto";
      isNormalUser = true;
      shell = pkgs.bash;
      extraGroups = [
        "podman"
        "wheel"
      ];
      hashedPassword = "$y$j9T$5qUofB6UibbNyT6gQ7nDX/$QpaTGYmim85ItVepaLalPmtPg1D/A6eFJj6YsCWMQfB";
      # https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode
      subUidRanges = [
        {
          startUid = 10000;
          count = 75535;
        }
      ];
      subGidRanges = [
        {
          startGid = 10000;
          count = 75535;
        }
      ];
    };
  };
}
