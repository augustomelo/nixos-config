{
  config,
  lib,
  ...
}:
let
  cfg = config.developerTools;
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
