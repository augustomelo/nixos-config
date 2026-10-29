#!/usr/bin/env bash

# Join a pane into the current window remembering where it came from,
# so it can be sent back later to the same place and layout.
#   join_pane.sh join <source-pane> <target-pane>
#   join_pane.sh return <pane>

pane_format(){
    tmux display-message -p -t "$1" "$2"
}

pane_position(){
    local pane=$1
    tmux list-panes -t "$pane" -F '#{pane_id}' | grep -nx -- "$pane" | cut -d: -f1
}

join(){
    local source_pane=$1
    local target_pane=$2
    local source_id

    source_id=$(pane_format "$source_pane" '#{pane_id}') || return

    # Side by side when the pane takes the full window height, stacked otherwise
    tmux set-option -p -t "$source_id" @origin "$(pane_format "$source_id" '#{session_name}:#{window_id}')"
    tmux set-option -p -t "$source_id" @origin_position "$(pane_position "$source_id")"
    tmux set-option -p -t "$source_id" @origin_layout "$(pane_format "$source_id" '#{window_layout}')"
    tmux set-option -p -t "$source_id" @origin_split "$(pane_format "$source_id" '#{?#{==:#{pane_height},#{window_height}},-h,-v}')"

    tmux join-pane -h -s "$source_id" -t "$target_pane"
}

clear_origin(){
    local pane=$1
    local option

    for option in @origin @origin_position @origin_layout @origin_split; do
        tmux set-option -pu -t "$pane" "$option"
    done
}

join_back(){
    local pane=$1
    local window=$2
    local position split layout
    local -a panes

    position=$(tmux show-options -pqv -t "$pane" @origin_position)
    split=$(tmux show-options -pqv -t "$pane" @origin_split)
    layout=$(tmux show-options -pqv -t "$pane" @origin_layout)
    mapfile -t panes < <(tmux list-panes -t "$window" -F '#{pane_id}')

    # Re-insert after the pane that was before it so the pane order matches the
    # saved layout. For the first position join after the first pane and swap,
    # since join-pane -b only places it before on screen, not in the pane order
    if [ "${position:-1}" -gt 1 ] && [ "$position" -le $((${#panes[@]} + 1)) ]; then
        tmux join-pane -d ${split:--h} -s "$pane" -t "${panes[$((position - 2))]}"
    else
        tmux join-pane -d ${split:--h} -s "$pane" -t "${panes[0]}"
        tmux swap-pane -d -s "$pane" -t "${panes[0]}"
    fi

    # Only succeeds when the window has the same panes as when the layout was saved
    tmux select-layout -t "$window" "$layout" 2>/dev/null
}

send_back(){
    local pane=$1
    local origin session window

    origin=$(tmux show-options -pqv -t "$pane" @origin)
    if [ -z "$origin" ]; then
        tmux display-message "Pane was not joined, nothing to send back"
        return
    fi

    session=${origin%%:*}
    window=${origin#*:}

    if tmux list-windows -t "$session" -F '#{window_id}' 2>/dev/null | grep -qx -- "$window"; then
        join_back "$pane" "$window"
    elif tmux has-session -t "$session" 2>/dev/null; then
        tmux break-pane -d -s "$pane" -t "$session:"
    else
        tmux break-pane -d -s "$pane"
    fi

    clear_origin "$pane"
}

case $1 in
    join) join "$2" "$3" ;;
    return) send_back "$2" ;;
esac
