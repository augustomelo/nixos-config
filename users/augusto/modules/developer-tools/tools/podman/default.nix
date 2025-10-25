{
  config,
  lib,
  ...
}:
let
  cfg = config.developer-tools;
in
{
  config = lib.mkIf cfg.enable {
    home = {
      file.".config/containers" = {
        source = ./containers;
        recursive = true;
      };
    };
  };
}
