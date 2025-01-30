{
  pkgs,
  config,
  ...
}: {

  catppuccin = {
    bat.enable = true;
    flavor = "macchiato";
    fzf.enable = true;
    k9s.enable = true;
    kvantum.enable = false;
    tmux = {
      enable = true;
      extraConfig = ''
        set -g @catppuccin_window_status_style "rounded"
        set -g @catppuccin_window_text " #W"
        set -g @catppuccin_window_current_text " #W"
      '';
    };
  };

  home = {
    file.".config" = { source = ./config; recursive = true; };
    file."${config.xdg.dataHome}/zsh" = { source = ./zsh recursive = true; };

    stateVersion = "24.11";
    sessionVariables = {
      BAT_THEME="Catppuccin Macchiato"; # this is needed for delta when running the command git blame
      DICPATH="$XDG_DATA_HOME/dictionaries"; # used by vale as other resources to dictionaries
      EDITOR="nvim";
      KUBECONFIG="$HOME/.kube/config";
    };

    packages = with pkgs; [
      cmake
      dasel
      delta
      docker-buildx
      docker-compose
      eza
      fd
      fzf-git-sh
      gcc
      git
      gnumake
      go
      home-manager
      hurl
      kubectl
      kubelogin-oidc
      neovim
      neovim 
      ripgrep
      starship
      vale
      xsel
      zsh-fzf-tab
    ];
  };


  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
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

    ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        font-size = 20;
        cursor-style = "block";
        link-url = true;
        mouse-hide-while-typing = true;
        shell-integration-features = "no-cursor";
        theme = "catppuccin-macchiato";
        title = "ghostty";
        window-decoration = false;
      };
    };

    k9s = {
      enable = true;
    };

    tmux = {
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 5;
      extraConfig = ''
        set-option -g display-time 4000
        set-option -g status-left ""
        set-option -g status-position top
        set-option -g window-status-separator ""
        set-option -gF  status-right "#{@catppuccin_status_directory}"

        bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "~/.tmux.conf reloaded"
        bind-key o run-shell -b "tmux capture-pane -J -p | grep -oE '(https?):\/\/.*[^>]' | fzf-tmux -d20 --multi --bind alt-a:select-all,alt-d:deselect-all | xsel --clipboard"
        bind-key s run-shell "tmux new-window ~/.config/zsh/functions/sessionizer"
        bind-key - split-window -v
        bind-key | split-window -h
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-selection
        bind-key -n M-h select-pane -L
        bind-key -n M-j select-pane -D
        bind-key -n M-k select-pane -U
        bind-key -n M-l select-pane -R

        unbind-key -T copy-mode-vi MouseDragEnd1Pane
        unbind-key '"'
        unbind-key %
      '';
      focusEvents = true;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-s";
    };

    zsh = {
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
        path = "$XDG_STATE_HOME/zsh/history";
        save = 50000;
        saveNoDups = true;
        size = 50000;
      };
      shellAliases = {
        g="git";
        hms="home-manager switch";
        k9s="k9s -c context";
        k="kubectl";
        la="eza --color=always --git --long --all";
        ll="eza --color=always --git --long";
        ls="eza --color=always --git";
      };
      initExtra = ''
        bindkey -s "^Z" " fg^M"

        for func in $XDG_DATA_HOME/zsh/functions/*(N:t); autoload $func

        zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
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
          src = "${pkgs.fzf-git-sh}/share/fzf-git-sh";
        }
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];
    };
  };

  imports = [
    ./activation/vale.nix
  ];

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    randomizedDelaySec = "10m";
    persistent = true;
    options = "--delete-older-than 15d";
  };
  
  xdg.enable = true;

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
}
