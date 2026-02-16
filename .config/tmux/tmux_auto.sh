#!/usr/bin/env bash

tmux_auto() {
  # If we are in filesystem root, just run normal tmux
  if [ "$PWD" = "/" ]; then
    command tmux "$@"
    return
  fi
  session_name=$(basename "$PWD")

  if tmux has-session -t="$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
  else
    tmux new-session -d -s "$session_name" -n "nvim" -c "$PWD" "nvim ."
    tmux new-window -t "$session_name:1" -c "$PWD"
    tmux new-window -t "$session_name:2" -c "$PWD"
    tmux select-window -t "$session_name:0"  # make sure nvim is active
    tmux attach-session -t "$session_name"
  fi
}
