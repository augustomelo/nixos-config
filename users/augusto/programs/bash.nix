{
  pkgs,
  config,
  ...
}:
{
  home.file."${config.xdg.dataHome}/bash" = {
    source = ../bash;
    recursive = true;
  };
  home.sessionPath = [
    "${config.xdg.dataHome}/bash"
  ];
  home.shell.enableBashIntegration = true;
  programs.bash = {
    enable = true;
    enableVteIntegration = true;
    historyControl = [
      "erasedups"
      "ignoreboth"
    ];
    historyFile = "${config.xdg.stateHome}/bash/history";
    historyIgnore = [
      "cd"
      "exit"
      "fg"
      "la"
      "ll"
      "ls"
    ];
    initExtra = ''
      # After each command, append to the history file and reread it
      PROMPT_COMMAND="history -a; history -c; history -r;$PROMPT_COMMAND"

      bind 'set show-all-if-ambiguous on'
      bind 'TAB:menu-complete'

      source "${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh";
    '';
    shellAliases = {
      g = "git";
      k = "kubectl";
      k9s = "k9s -c context";
      la = "eza --color=always --git --long --all";
      ll = "eza --color=always --git --long";
      ls = "eza --color=always --git";
      nfu = "nix flake update --flake $HOME/workspace/personal/nixos-config/";
      nrs = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nixos-config/#";
      tmux = "tmux attach -dt nixos-config || tmux new-session -s nixos-config -c \"$HOME/workspace/personal/nixos-config/\"";
    };
    shellOptions = [
      "cdspell"
      "globstar"
      "histappend"
    ];
  };
}
