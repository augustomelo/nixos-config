{
  pkgs,
  config,
  ...
}:
{
  home.file.".local/share/zsh" = {
    source = ../zsh;
    recursive = true;
  };
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "emacs";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      path = "${config.xdg.stateHome}/zsh/history";
      save = 50000;
      saveNoDups = true;
      size = 50000;
    };
    shellAliases = {
      g = "git";
      k = "kubectl";
      k9s = "k9s -c context";
      la = "eza --color=always --git --long --all";
      ll = "eza --color=always --git --long";
      ls = "eza --color=always --git";
      nrs = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nixos-config/#vm-aarch64-fusion";
      nfu = "nix flake update --flake $HOME/workspace/personal/nixos-config/";
      tmux = "tmux attach -dt nixos-config || tmux new-session -s nixos-config -c \"$HOME/workspace/personal/nixos-config/\"";
    };
    initContent = ''
      bindkey -s "^Z" " fg^M"

      fpath+="${config.xdg.dataHome}/zsh/functions"
      for func in ${config.xdg.dataHome}/zsh/functions/*(N:t); autoload $func

      CACHEFILE="${config.xdg.cacheHome}/zsh/.zcompcache"
      mkdir -p "$(dirname "$CACHEFILE")"
      zstyle ':completion:*' cache-path "$CACHEFILE"
      zstyle ':completion:*' use-cache on
    '';
    plugins = [
      {
        name = "fzf-git-sh";
        file = "fzf-git.sh";
        src = "${pkgs.fzf-git-sh}/share/fzf-git-sh";
      }
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];
  };
}
