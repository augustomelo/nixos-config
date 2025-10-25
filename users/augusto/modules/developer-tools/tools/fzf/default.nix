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
    programs.fzf = {
      enable = true;
      changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidgetOptions = [
        "--preview 'eza --tree --color=always {} | head -200'"
      ];
      defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      defaultOptions = [
        "--bind 'ctrl-u:preview-up,ctrl-d:preview-down'"
      ];
      fileWidgetCommand = "fd --type=f --hidden --strip-cwd-prefix --exclude .git";
      fileWidgetOptions = [
        "--preview 'bat --number --color=always --line-range :500 {}'"
      ];
    };
  };
}
