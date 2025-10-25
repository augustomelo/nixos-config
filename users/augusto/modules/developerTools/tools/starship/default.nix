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
    home.file.".config/starship.toml" = {
      source = ./starship.toml;
    };

    programs.starship = {
      enable = true;
    };
  };
}
