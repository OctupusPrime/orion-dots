#!/bin/bash

# --- Usage ---
# ./change-timezone.sh America/New_York

NEW_TZ="$1"

# Check if argument is provided
if [ -z "$NEW_TZ" ]; then
    echo "Error: No timezone specified."
    echo "Usage: $0 <Region/City>"
    echo "Example: $0 America/New_York"
    exit 1
fi

# Check current timezone
CURRENT_TZ=$(timedatectl show --property=Timezone --value)

if [ "$CURRENT_TZ" == "$NEW_TZ" ]; then
    echo "System is already set to timezone '$CURRENT_TZ'. No changes required."
    exit 0
fi

if timedatectl set-timezone "$NEW_TZ"; then
    echo "Success: Timezone updated to '$NEW_TZ'."
else
    echo "Error: Failed to set timezone. Please ensure '$NEW_TZ' is a valid timezone."
    exit 1
fi