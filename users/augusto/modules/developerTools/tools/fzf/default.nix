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
    programs.fzf = {
      enable = true;
      changeDirWidget = {
        command = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
        options = [
          "--preview 'eza --tree --color=always {} | head -200'"
        ];
      };
      defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      defaultOptions = [
        "--ansi"
        "--bind 'ctrl-u:preview-up,ctrl-d:preview-down'"
      ];
      fileWidget = {
        command = "fd --type=f --hidden --strip-cwd-prefix --exclude .git";
        options = [
          "--preview 'bat --number --color=always --line-range :500 {}'"
        ];
      };
    };
  };
}
