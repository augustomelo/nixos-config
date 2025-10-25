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
    home.file.".config/jj" = {
      source = ./jj;
      recursive = true;
    };

    programs.jujutsu = {
      enable = true;
    };
  };
}
