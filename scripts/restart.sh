#!/bin/bash

tmux send-keys -t $TMUX_SESSION "stop" ENTER
echo "Stopping Minecraft server..."

# While the server is stopping, we want to keep checking if it's still running
# If it's still running, we want to keep waiting
# If it's not running, we want to break out of the loop
while true; do
    if tmux capture-pane -pt $TMUX_SESSION | grep -q "Closing Server"; then
        break
    fi
    sleep 1
done

# Close the tmux session
tmux kill-session -t $TMUX_SESSION

echo "Minecraft server stopped, restarting..."
tmux send-keys -t $TMUX_SESSION "start" ENTER
