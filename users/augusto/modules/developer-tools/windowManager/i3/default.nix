{
  config,
  lib,
  ...
}:
let
  cfg = config.developer-tools.windowManager.i3;
in
{
  config = lib.mkIf cfg.enable {
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        terminal = "ghostty";
        modifier = "Mod4";
        startup = [
          { command = "exec xrandr --dpi 220"; }
        ];
      };
    };
  };
}
