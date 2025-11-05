#!/usr/bin/env bash

dir="~/.config/polybar/cuts/scripts/rofi"

# Rofi command
rofi_command="rofi -no-config -theme $dir/bluetooth.rasi"

# Icons
ICON_ON=""
ICON_OFF=""
ICON_CONN=""
ICON_DISCONN=" Disconnect"

# Get bluetooth status
bluetooth_status() {
    if (bluetoothctl show | grep -q "Powered: yes"); then
        echo "on"
    else
        echo "off"
    fi
}

# Get connected device
connected_device() {
    if (bluetoothctl info | grep -q "Connected: yes"); then
        bluetoothctl info | grep "Name" | cut -d ' ' -f 2-
    else
        echo ""
    fi
}

# Rofi menu options
options() {
    if [ "$(bluetooth_status)" == "on" ]; then
        echo "$ICON_OFF Turn Off"
        if [ -n "$(connected_device)" ]; then
            echo "$ICON_DISCONN"
        else
            echo "$ICON_CONN Connect"
        fi
    else
        echo "$ICON_ON Turn On"
    fi
}

# Main function to display status
print_status() {
    STATUS=$(bluetooth_status)
    DEVICE=$(connected_device)

    if [ "$STATUS" == "on" ]; then
        if [ -n "$DEVICE" ]; then
            echo "$ICON_CONN $DEVICE"
        else
            echo "$ICON_ON"
        fi
    else
        echo "$ICON_OFF"
    fi
}

# Function to show rofi menu and handle actions
show_menu() {
    chosen="$(options | $rofi_command -p "Bluetooth" -dmenu -selected-row 0)"
    case "$chosen" in
        "$ICON_ON Turn On")
            bluetoothctl power on
            ;;
        "$ICON_OFF Turn Off")
            bluetoothctl power off
            ;;
        "$ICON_CONN Connect")
            # Notify user
            rofi -e "Scanning for devices..." -theme $dir/message.rasi &
            SCAN_PID=$!
            
            # Scan for 5 seconds
            timeout 5s bluetoothctl scan on > /dev/null
            kill $SCAN_PID

            # Get available devices
            devices=$(bluetoothctl devices | cut -d ' ' -f 2-)

            if [ -z "$devices" ]; then
                rofi -e "No devices found" -theme $dir/message.rasi
                exit 0
            fi

            # Select device from Rofi
            chosen_device=$(echo "$devices" | rofi -dmenu -p "Scan Results" -theme $dir/bluetooth.rasi)

            if [ -n "$chosen_device" ]; then
                # Get MAC address
                mac_address=$(echo "$devices" | grep "$chosen_device" | cut -d ' ' -f 1)
                # Attempt to connect
                bluetoothctl connect "$mac_address"
            fi
            ;;
        "$ICON_DISCONN")
            # Get the MAC address of the currently connected device
            connected_mac=$(bluetoothctl info | grep "Device" | cut -d ' ' -f 2)
            if [ -n "$connected_mac" ]; then
                bluetoothctl disconnect "$connected_mac"
            fi
            ;;
    esac
}

# Function to continuously print status for Polybar
run_polybar_update() {
    while true; do
        print_status
        sleep 5 # Update interval
    done
}

# Handle arguments
case "$1" in
    --menu)
        show_menu
        ;;
    *)
        run_polybar_update
        ;;
esac
