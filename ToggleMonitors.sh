#!/bin/bash

################################################################################

# Run this script without any arguments to switch between the following:
# 1. Internal monitor only
# 2. External monitor only
# 3. Both monitors, with internal as primary
# 4. Both monitors, with external as primary
# The following variables must be set
# For $internal and $external, refer to the output of `xrandr --listmonitors

state_file=/tmp/toggle_monitors.state
internal="eDP-1"
external="HDMI-1"
# If your internal display is to the left and external one to the right.
position="--left-of"

############ end of documentation and configuration ############################

# Let's get both the positions right.
if [[ "$position" == "--left-of" ]]
then
    reverse_position="--right-of"
else
    position="--left-of"
    reverse_position="--left-of"
fi

state="internal"
if [[ -f $state_file ]]
then
    state=$(cat $state_file)
    if [[ $state != "internal_primary" && $state != "internal_only"
        && $state != "external_primary" && $state != "external_only" ]]
    then
        state="internal_primary"
    fi
fi

if [[ $state == "internal_primary" ]]
then
    # Switch to internal only
    xrandr --output "$internal" --auto --output "$external" --off
    echo -n "internal_only" > $state_file
    notify-send "ToggleMonitors: Set to internal only"
elif [[ $state == "internal_only" ]]
then
    # Switch to external_primary
    xrandr --output "$external" --auto --primary --output "$internal" $position "$external" 
    echo -n "external_primary" > $state_file
    notify-send "ToggleMonitors: Set to external primary"
elif [[ $state == "external_primary" ]]
then
    # Switch to external_only
    xrandr --output "$internal" --off --output "$external" --auto
    echo -n "external_only" > $state_file
    notify-send "ToggleMonitors: Set to external only"
else
    # Switch to internal_primary
    xrandr --output "$internal" --auto --primary --output "$external" $reverse_position "$internal" --auto
    echo -n "internal_primary" > $state_file
    notify-send "ToggleMonitors: Set to internal primary"
fi
