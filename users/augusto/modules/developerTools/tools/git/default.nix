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
    home.file.".config/git" = {
      source = ./git;
      recursive = true;
    };

    programs.git = {
      enable = true;
    };
  };
}
