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
    programs.tmux = {
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      extraConfig = ''
        set-option -g display-time 4000
        set-option -g renumber-windows on
        set-option -g status-left "  "
        set-option -g window-status-current-format "●"
        set-option -g window-status-format "●"
        set-option -g window-status-separator "  "
        set-option -g status-right " #S "

        # https://github.com/catppuccin/tmux/blob/main/themes/catppuccin_macchiato_tmux.conf
        set-option -gF status-style "bg=#{@thm_surface_1},fg=#{@thm_fg}"
        set-option -g window-status-current-style "#{?window_zoomed_flag,fg=#{@thm_yellow},fg=#{@thm_mauve},nobold}"
        set-option -g window-status-bell-style "fg=#{@thm_red},nobold"

        bind-key r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display-message "~/.tmux.conf reloaded"
        bind-key o run-shell -b "tmux capture-pane -J -p | grep -oE '(https?):\/\/.*[^>]' | fzf-tmux -d20 --multi | xargs xdg-open"
        bind-key s display-popup -E "sessionizer.sh"
        bind-key C-t display-popup -d "#{pane_current_path}" -E "bash -i"
        bind-key - split-window -v
        bind-key | split-window -h
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-selection
        bind C-l send-keys 'C-l' # since I am usin C-l to move windos this is needed

        unbind-key -T copy-mode-vi MouseDragEnd1Pane
        unbind-key '"'
        unbind-key %
      '';
      focusEvents = true;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-s";
      plugins = with pkgs; [
        tmuxPlugins.vim-tmux-navigator
      ];
      terminal = "screen-256color";
    };
  };
}
