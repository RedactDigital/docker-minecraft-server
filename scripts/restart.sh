#!/bin/bash

LAST_LINE=$(tail -3 $WORKDIR/logs/latest.log)

# See if the tmux session exists
# If it doesn't exist, we know the server isn't running
# so we can start it
if ! tmux has-session -t $TMUX_SESSION 2>/dev/null; then
    echo "Minecraft server is not running! Starting..."
    bash $WORKDIR/scripts/start.sh
    exit 0
fi

# If the tmux session exists, we want to see if the server is still running
# If it isn't, we want to start it
# We can check if the server is still running by checking the log file
# If the last line of the log file contains "Closing Server", we know the server has stopped
# If it doesn't contain "Closing Server", we know the server is still running
if echo "$LAST_LINE" | grep -q "Closing Server"; then
    echo "Minecraft server is not running! Starting..."
    bash $WORKDIR/scripts/start.sh
    exit 0
fi

# If we get to this point, we know the server is running
# So we want to stop it
tmux send-keys -t $TMUX_SESSION "stop" ENTER
echo "Stopping Minecraft server..."

# While the server is stopping, we want to keep checking if it's still running
# If it's still running, we want to keep waiting
# If it's not running, we want to break out of the loop
while true; do
    # If the last line of the log file contains "Closing Server", we know the server has stopped
    if echo "$LAST_LINE" | grep -q "Closing Server"; then
        echo "Server has stopped!"
        break
    fi
    sleep 1
done

# Now that the server has stopped, we want to start it again
# We can do this by running the start.sh script we already have
echo "Minecraft server stopped, restarting..."
bash $WORKDIR/scripts/start.sh
