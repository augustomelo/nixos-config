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
      file.".config/starship.toml" = {
        source = ./starship.toml;
        recursive = true;
      };
    };

    programs.starship = {
      enable = true;
    };
  };
}
