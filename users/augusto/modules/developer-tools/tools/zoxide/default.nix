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
    programs.zoxide = {
      enable = true;
    };
  };
}
