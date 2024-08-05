#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/utils.sh"

ORIGIN_SESSION=$(tmux display -p '#{session_name}')       # Neu: Speichern des Ursprungssessionsnamens
tmux setenv -g ORIGIN_SESSION "$ORIGIN_SESSION"
SCRATCH_SESSION="${ORIGIN_SESSION}_scratch"              # Neu: Erstellen eines eindeutigen Scratch-Session-Namens

if [ "$(tmux display-message -p '#{session_name}')" = "$SCRATCH_SESSION" ]; then  # Geändert: Vergleich mit spezifischer Scratch-Session
    unset_bindings

    if [ -z "$FLOAX_TITLE" ]; then
        FLOAX_TITLE="$DEFAULT_TITLE"
    fi

    change_popup_title "$FLOAX_TITLE"
    tmux setenv -g FLOAX_TITLE "$FLOAX_TITLE"
    tmux detach-client
else
    # Check if the specific scratch session exists
    if tmux has-session -t "$SCRATCH_SESSION" 2>/dev/null; then  # Geändert: Überprüfung der spezifischen Scratch-Session
        set_bindings
        tmux_popup
    else
        # Create a new session with a unique name and attach to it
        tmux new-session -d -c "$(tmux display-message -p '#{pane_current_path}')" -s "$SCRATCH_SESSION"  # Geändert: Erstellen der spezifischen Scratch-Session
        tmux set-option -t "$SCRATCH_SESSION" status off
        tmux_popup
    fi
fi

