{
  config,
  lib,
  ...
}:
{
  imports = [
    ./media.nix
    ./nas.nix
    ./network.nix
    ./podman.nix
    ./servarr.nix
  ];

  options.home-server.containers = {
    enable = lib.mkEnableOption "Enable home-server containers";
    root = {
      config = lib.mkOption {
        type = lib.types.path;
        default = "${config.home.homeDirectory}/containers/config";
      };
      storage = lib.mkOption {
        type = lib.types.path;
        default = "${config.home.homeDirectory}/containers/storage";
      };
    };
    stack = {
      media.enable = lib.mkEnableOption "Enable media stack";
      nas.enable = lib.mkEnableOption "Enable nas stack";
      network.enable = lib.mkEnableOption "Enable network stack";
      servarr.enable = lib.mkEnableOption "Enable servarr stack";
    };
  };

  config = lib.mkIf config.home-server.containers.enable {
    home-server.containers.stack.media.enable = true;
    home-server.containers.stack.nas.enable = true;
    home-server.containers.stack.network.enable = true;
    home-server.containers.stack.servarr.enable = true;
  };
}
