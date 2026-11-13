#!/usr/bin/env bash

set -u

HWMON="/sys/class/hwmon/hwmon5"

PWM="$HWMON/pwm1"
PWM_ENABLE="$HWMON/pwm1_enable"
FAN_RPM="$HWMON/fan1_input"

# Intel CPU temperature
TEMP="/sys/class/hwmon/hwmon6/temp1_input"

# --------------------------------------------------
# Check
# --------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

if [[ ! -e "$PWM" || ! -e "$PWM_ENABLE" ]]; then
    echo "ERROR: Dell PWM fan control not found."
    exit 1
fi

# --------------------------------------------------
# Read values
# --------------------------------------------------

temperature() {
    awk '{printf "%.1f", $1 / 1000}' "$TEMP"
}

rpm() {
    cat "$FAN_RPM"
}

pwm() {
    cat "$PWM"
}

# --------------------------------------------------
# Set PWM
# --------------------------------------------------

set_pwm() {
    local value="$1"

    (( value < 0 )) && value=0
    (( value > 255 )) && value=255

    echo 1 > "$PWM_ENABLE"
    echo "$value" > "$PWM"
}

# --------------------------------------------------
# Percentage → PWM
# --------------------------------------------------

set_percent() {
    local percent="$1"
    local value

    (( percent < 0 )) && percent=0
    (( percent > 100 )) && percent=100

    value=$(( percent * 255 / 100 ))

    set_pwm "$value"

    echo "Fan: ${percent}% (PWM ${value}/255)"
}

# --------------------------------------------------
# Maximum
# --------------------------------------------------

max() {
    set_pwm 255

    echo
    echo "🚀 MAXIMUM FAN"
    echo "PWM : $(pwm)/255"
    echo "RPM : $(rpm)"
}

# --------------------------------------------------
# Status
# --------------------------------------------------

status() {
    echo
    echo "=============================="
    echo "       DELL FAN STATUS"
    echo "=============================="
    echo "Temperature : $(temperature) °C"
    echo "Fan RPM     : $(rpm)"
    echo "PWM         : $(pwm)/255"
    echo "PWM Enable  : $(cat "$PWM_ENABLE")"
    echo "Maximum RPM : 6600"
    echo "=============================="
}

# --------------------------------------------------
# Automatic temperature curve
# --------------------------------------------------

automatic() {

    echo
    echo "Automatic fan control started."
    echo "CTRL+C → return to previous PWM"
    echo

    trap 'echo; echo "Automatic mode stopped."; exit 0' INT TERM

    while true; do

        temp=$(temperature)
        temp_int=${temp%.*}

        if (( temp_int < 45 )); then
            percent=20

        elif (( temp_int < 55 )); then
            percent=30

        elif (( temp_int < 65 )); then
            percent=45

        elif (( temp_int < 70 )); then
            percent=60

        elif (( temp_int < 75 )); then
            percent=75

        elif (( temp_int < 80 )); then
            percent=90

        else
            percent=100
        fi

        value=$(( percent * 255 / 100 ))

        set_pwm "$value"

        printf "\r🌡️  %s°C | 🌀 %3s%% | %4s RPM | PWM %3s/255   " \
            "$temp" "$percent" "$(rpm)" "$value"

        sleep 3
    done
}

# --------------------------------------------------
# Manual
# --------------------------------------------------

manual() {

    echo
    read -rp "Fan percentage (0-100): " percent

    if ! [[ "$percent" =~ ^[0-9]+$ ]]; then
        echo "Invalid value."
        return
    fi

    set_percent "$percent"
}

# --------------------------------------------------
# Menu
# --------------------------------------------------

while true; do

    clear

    echo "╔══════════════════════════════════╗"
    echo "║       DELL FAN CONTROL           ║"
    echo "╠══════════════════════════════════╣"
    printf "║ 🌡️  Temperature : %-12s ║\n" "$(temperature) °C"
    printf "║ 🌀 Fan RPM     : %-12s ║\n" "$(rpm)"
    printf "║ 🎚️  PWM         : %-12s ║\n" "$(pwm)/255"
    echo "╠══════════════════════════════════╣"
    echo "║ 1) 🚀 Maximum fan               ║"
    echo "║ 2) 🎚️  Manual percentage        ║"
    echo "║ 3) 🤖 Automatic temperature     ║"
    echo "║ 4) 📊 Status                    ║"
    echo "║ 5) Exit                         ║"
    echo "╚══════════════════════════════════╝"
    echo

    read -rp "Select: " choice

    case "$choice" in

        1)
            max
            read -rp "Press Enter..."
            ;;

        2)
            manual
            read -rp "Press Enter..."
            ;;

        3)
            automatic
            ;;

        4)
            status
            read -rp "Press Enter..."
            ;;

        5)
            echo "Exiting. Current fan setting remains active."
            exit 0
            ;;

        *)
            echo "Invalid option."
            sleep 1
            ;;

    esac

done
