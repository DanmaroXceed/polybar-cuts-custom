#!/bin/bash

# Simplified find_player function that is confirmed to work
find_player() {
    for player in $(playerctl -l); do
        if [[ $player == "brave"* ]]; then
            echo "$player"
            return
        fi
    done
}

PLAYER=$(find_player)

if [ -z "$PLAYER" ]; then
    echo ""
    exit
fi

# Get metadata
STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)
ARTIST=$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)
TITLE=$(playerctl --player="$PLAYER" metadata title 2>/dev/null)

# Check if metadata is available. If not, display "Buscando..."
if [ -z "$STATUS" ] || [ -z "$TITLE" ]; then
    echo "Buscando..."
    exit
fi

# Truncate song info
SONG_INFO=""
if [ -n "$ARTIST" ]; then
    SONG_INFO="$ARTIST - $TITLE"
else
    SONG_INFO="$TITLE"
fi
if [ ${#SONG_INFO} -gt 25 ]; then
    SONG_INFO="$(echo "$SONG_INFO" | cut -c1-25)..."
fi

# Define icons based on the original mpd module
ICON_PREV=""
ICON_NEXT=""
if [ "$STATUS" = "Playing" ]; then
    ICON_PLAY_PAUSE="" # Pause icon
else
    ICON_PLAY_PAUSE="" # Play icon
fi

# Build the output with clickable Polybar actions
# Wrap commands in a subshell to suppress errors from playerctl if it fails
PREV_ACTION="%{A1:playerctl --player=\"$PLAYER\" previous 2>/dev/null:}$ICON_PREV%{A}"
PLAY_PAUSE_ACTION="%{A1:playerctl --player=\"$PLAYER\" play-pause 2>/dev/null:}$ICON_PLAY_PAUSE%{A}"
NEXT_ACTION="%{A1:playerctl --player=\"$PLAYER\" next 2>/dev/null:}$ICON_NEXT%{A}"

# Make the song info text also clickable for play/pause
CLICKABLE_SONG_INFO="%{A1:playerctl --player=\"$PLAYER\" play-pause 2>/dev/null:}$SONG_INFO%{A}"

# Final output string
echo "$CLICKABLE_SONG_INFO $PREV_ACTION $PLAY_PAUSE_ACTION $NEXT_ACTION"