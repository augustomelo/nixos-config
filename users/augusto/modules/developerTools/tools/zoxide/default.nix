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
    programs.zoxide = {
      enable = true;
    };
  };
}
