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
    dotDir = ".config/zsh";
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

      # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
      # - The first argument to the function ($1) is the base path to start traversal
      # - See the source code (completion.{bash,zsh}) for the details.
      _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
      }

      # Use fd to generate the list for directory completion
      _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
      }

      show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

      # Advanced customization of fzf options via _fzf_comprun function
      # - The first argument to the function is the name of the command.
      # - You should make sure to pass the rest of the arguments to fzf.
      _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
          cd) fzf --preview "eza --tree --color=always {} | head -200" "$@" ;;
          export|unset) fzf --preview "eval 'echo $'{}" "$@" ;;
          *) fzf --preview "$show_file_or_dir_preview" "$@" ;;
        esac
      }
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
