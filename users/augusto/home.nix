{
  pkgs,
  config,
  ...
}:
{

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
    file.".config" = {
      source = ./config;
      recursive = true;
    };
    file.".local/share/zsh" = {
      source = ./zsh;
      recursive = true;
    };

    stateVersion = "24.11";
    sessionVariables = {
      BAT_THEME = "Catppuccin Macchiato"; # this is needed for delta when running the command git blame
      EDITOR = "nvim";
      KUBECONFIG = "$HOME/.kube/config";
      JAVA_TOOL_OPTIONS="-javaagent:${pkgs.lombok}/share/java/lombok.jar -XX:UseSVE=0"; # use this until this PR is merged NixOS/nixpkgs#379073 or someone bump jdk version
    };

    packages = with pkgs; [
      cmake
      dasel
      dbeaver-bin
      delta
      docker-buildx
      docker-compose
      eza
      fd
      firefox
      fzf-git-sh
      gcc
      git
      gnumake
      go
      home-manager
      hurl
      jdk
      kubectl
      kubelogin-oidc
      lombok
      nixfmt-rfc-style
      nodejs_23
      python314
      ripgrep
      unzip
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

    neovim = {
      enable = true;

      extraPackages = with pkgs; [
        gopls
        helm-ls
        jdt-language-server
        lua-language-server
        nil
        nixfmt-rfc-style
        python313Packages.python-lsp-server
        vale-ls
        yaml-language-server
      ];
    };

    starship.enable = true;

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
        set-option -gF  status-right "#{@catppuccin_status_session}"

        bind-key r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display-message "~/.tmux.conf reloaded"
        bind-key o run-shell -b "tmux capture-pane -J -p | grep -oE '(https?):\/\/.*[^>]' | fzf-tmux -d20 --multi --bind alt-a:select-all,alt-d:deselect-all | xsel --clipboard"
        bind-key s run-shell "tmux new-window ${config.xdg.dataHome}/zsh/functions/sessionizer"
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

    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
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
        nixswitch = "sudo nixos-rebuild switch --flake $HOME/workspace/personal/nixos-config/#vm-aarch64-fusion";
        nixupdate = "nix flake update --flake $HOME/workspace/personal/nixos-config/";
        tmux = "tmux attach -dt nixos-config || tmux new-session -s nixos-config -c \"$HOME/workspace/personal/nixos-config/\"";
      };
      initExtra = ''
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
  };

  imports = [
    ./activation/vale.nix
  ];

  nix.gc = {
    automatic = true;
    frequency = "daily";
    randomizedDelaySec = "10m";
    persistent = true;
    options = "--delete-older-than 3d";
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
