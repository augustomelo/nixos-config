{
  config,
  lib,
  ...
}:
{
  imports = [
    ./media
    ./nas
    ./network
    ./podman.nix
    ./servarr
  ];

  options.homeServer.containers = {
    enable = lib.mkEnableOption "Enable home-server containers";
    directory = {
      config = lib.mkOption {
        type = lib.types.path;
        default = "${config.home.homeDirectory}/containers/config";
      };
      share = lib.mkOption {
        type = lib.types.path;
        default = "${config.home.homeDirectory}/containers/share";
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

  config = lib.mkIf config.homeServer.containers.enable {
    homeServer.containers.stack.media.enable = true;
    homeServer.containers.stack.nas.enable = true;
    homeServer.containers.stack.network.enable = true;
    homeServer.containers.stack.servarr.enable = true;
  };
}
