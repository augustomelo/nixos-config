{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.developer-tools;
in
{
  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
    };
  };
}
