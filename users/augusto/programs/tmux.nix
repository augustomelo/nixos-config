{
  config,
  ...
}:
{
  programs.tmux = {
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
      bind-key o run-shell -b "tmux capture-pane -J -p | grep -oE '(https?):\/\/.*[^>]' | fzf-tmux -d20 --multi | xargs xdg-open"
      bind-key s display-popup -E "zsh ${config.xdg.dataHome}/zsh/functions/sessionizer"
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
    terminal = "screen-256color";
  };
}
