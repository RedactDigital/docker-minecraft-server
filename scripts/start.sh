#!/bin/bash

COMMAND="java -Xms12288M -Xmx12288M --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -jar $WORKDIR/paper.jar --nogui"

# See if a tmux session already exists, if it doesn't, create one
if ! tmux has-session -t "$TMUX_SESSION"; then
    echo "Creating new tmux session..."
    tmux new-session -d -s "$TMUX_SESSION"
fi

echo "Starting Minecraft server..."
tmux send-keys -t "$TMUX_SESSION" "$COMMAND" ENTER

# While the server is starting, we want to keep checking if it's still starting
# If it's still starting, we want to keep waiting
# If it's not starting, we want to break out of the loop
while true; do
    if tmux capture-pane -pt "$TMUX_SESSION" | grep -q "Done"; then
        break
    fi
    sleep 1
done

echo "Minecraft server started"
