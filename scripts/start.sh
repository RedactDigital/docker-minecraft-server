#!/bin/bash

COMMAND="java -Xms12G -Xmx12G --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -jar $WORKDIR/paper*.jar --nogui"

# See if a tmux session already exists, if it doesn't, create one
if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
    echo "Creating new tmux session..."
    tmux new-session -d -s "$TMUX_SESSION"
fi

echo "Starting Minecraft server..."
tmux send-keys -t "$TMUX_SESSION" "$COMMAND" ENTER

# While the server is starting, we want to keep checking if it's still starting
# If it's still starting, we want to keep waiting
# If it's not starting, we want to break out of the loop
while true; do
    # Get the last line of the log file
    LAST_LINE=$(tail -3 $WORKDIR/logs/latest.log)

    # If the last line of the log contains "Closing Server", the new log file probably
    # hasn't been created yet, so we want to keep waiting
    if echo "$LAST_LINE" | grep -q "Closing Server"; then
        sleep 1
        continue
    fi

    # If the last line of the log file contains "Done", we know the server has started
    if echo "$LAST_LINE" | grep -q "Done"; then
        echo "Server has started!"
        break
    fi
    sleep 1
done

CONFIG_FILES="banned-ips.json banned-players.json bukkit.yml commands.yml help.yml ops.json permissions.yml server.properties spigot.yml whitelist.json"

# These files are in the $WORKDIR/config folder so we need to do some extra logic
# when checking if they exist and creating the symlink
PAPER_CONFIG_FILES="paper-global.yml paper-world-defaults.yml"

# If there is a /config directory mounted, we will loop through all the CONFIG_FILES
# and check if they exist in /config. If they don't, we will copy the ones that
# that are missing from the WORKDIR to /config
if [ -d /config ]; then
    for file in $CONFIG_FILES; do
        if [ ! -f /config/$file ]; then
            echo "Copying $file to /config"
            cp $WORKDIR/$file /config/$file
        fi
    done

    # We are doing the same thing as above, but for the PAPER_CONFIG_FILES
    for file in $PAPER_CONFIG_FILES; do
        if [ ! -f /config/$file ]; then
            echo "Copying $file to /config"
            cp $WORKDIR/config/$file /config/$file
        fi
    done

    # Now we loop through all the files in it and create a symlink to them.
    # Since we already checked if the file exists in /config, we don't need to
    # check if the file exists in /config before creating the symlink
    for file in $CONFIG_FILES; do
        filename=$(basename $file)
        if [ -f $WORKDIR/$filename ]; then
            echo "Removing $filename from $WORKDIR so we can create a symlink"
            rm $WORKDIR/$filename
        fi
        echo "Creating symlink for $filename"
        ln -s /config/$file $WORKDIR/$filename
    done

    # We are doing the same thing as above, but for the PAPER_CONFIG_FILES
    for file in $PAPER_CONFIG_FILES; do
        filename=$(basename $file)
        if [ -f $WORKDIR/config/$filename ]; then
            echo "Removing $filename from $WORKDIR/config so we can create a symlink"
            rm $WORKDIR/config/$filename
        fi
        echo "Creating symlink for $filename"
        ln -s /config/$file $WORKDIR/config/$filename
    done
fi

# Create a reusable function to check if a file exists and create a symlink to it
