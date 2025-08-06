#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
  selected_cwd=$1
else
  selected_cwd=$({ fd . --type d --max-depth 1 ~/workspace/personal; fd . --type d --max-depth 2 ~/workspace/work; } | fzf --preview "eza --tree --color=always {}")
fi

if [[ -z $selected_cwd ]]; then
  return 0
fi

selected_name=$(basename "$selected_cwd" | tr . _)

if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected_cwd"
fi

tmux switch-client -t "$selected_name"
