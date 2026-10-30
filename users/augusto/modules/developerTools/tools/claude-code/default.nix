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
    programs.claude-code = {
      enable = true;
      settings = {
        model = "opus";
        tui = "fullscreen";
        permissions = {
          disableAutoMode = "disable";
        };
      };
    };
  };
}
