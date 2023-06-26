#!/bin/bash

tmux send-keys -t $TMUX_SESSION "stop" ENTER
echo "Stopping Minecraft server..."

# While the server is stopping, we want to keep checking if it's still running
# If it's still running, we want to keep waiting
# If it's not running, we want to break out of the loop
while true; do
    # Get the last line of the log file
    LAST_LINE=$(tail -3 $WORKDIR/logs/latest.log)

    # If the last line of the log file contains "Closing Server", we know the server has stopped
    if echo "$LAST_LINE" | grep -q "Closing Server"; then
        echo "Server has stopped!"
        break
    fi
    sleep 1
done

# Close the tmux session
tmux kill-session -t $TMUX_SESSION
echo "Minecraft server stopped!"
