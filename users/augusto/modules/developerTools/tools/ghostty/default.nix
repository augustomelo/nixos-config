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
    programs.ghostty = {
      enable = true;
      settings = {
        font-size = 22;
        cursor-style = "block";
        link-url = true;
        mouse-hide-while-typing = true;
        shell-integration-features = "no-cursor";
        theme = "Catppuccin Macchiato";
        title = "ghostty";
        window-decoration = false;
      };
    };
  };
}
