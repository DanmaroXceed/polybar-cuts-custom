#!/usr/bin/env bash

# Configuration
BAR_WIDTH=5
FILLED_ICON="ﭳ"
EMPTY_ICON="ﭳ" # Using the same icon for a solid background look

# Function to generate the bar
get_bar() {
    # Get brightness percentage (and remove the '%' sign)
    PERCENTAGE=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

    # Calculate how many segments of the bar should be 'filled'
    FILLED_COUNT=$(( (PERCENTAGE * BAR_WIDTH) / 100 ))
    # Calculate the 'empty' segments
    EMPTY_COUNT=$(( BAR_WIDTH - FILLED_COUNT ))

    # Assemble the bar strings
    FILLED_BAR=$(for i in $(seq 1 $FILLED_COUNT); do echo -n "$FILLED_ICON"; done)
    EMPTY_BAR=$(for i in $(seq 1 $EMPTY_COUNT); do echo -n "$EMPTY_ICON"; done)

    # Output the bar with Polybar formatting
    # The filled part will be red, the empty part will be a darker grey.
    echo "%{F#ff5250}$FILLED_BAR%{F-}%{F#444}$EMPTY_BAR%{F-}"
}

# Handle script arguments
case "$1" in
    --up)
        # Increase brightness and trigger a Polybar update
        brightnessctl set +5%
        polybar-msg action brightness update
        ;;
    --down)
        # Decrease brightness and trigger a Polybar update
        brightnessctl set 5%-
        polybar-msg action brightness update
        ;;
    *)
        # Default action: print the bar
        get_bar
        ;;
esac