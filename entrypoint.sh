#!/bin/bash

# Create the eula file if it doesn't exist
if [ ! -f $WORKDIR/eula.txt ]; then
    echo "eula=$EULA" >$WORKDIR/eula.txt
fi

# If the /config has been mounted, loop through all the files in it
# and create a symlink to them. If the file already exists, rename
# it to .bak and then create the symlink
if [ -d /config ]; then
    for file in /config/*; do
        filename=$(basename $file)
        if [ -f $WORKDIR/$filename ]; then
            echo "File $filename already exists, renaming to $filename.bak"
            mv $WORKDIR/$filename $WORKDIR/$filename.bak
        fi
        echo "Creating symlink for $filename"
        ln -s $file $WORKDIR/$filename
    done
fi

# Start the server script without waiting for it to finish
# The & at the end of the line tells bash to run the command in the background
# so that it doesn't block the rest of the script from running and we can
# tail the log file while the server is starting rather than waiting for it
# to finish starting
bash $WORKDIR/scripts/start.sh &

# Wait for the log file to be created before tailing it
while [ ! -f $WORKDIR/logs/latest.log ]; do
    sleep 1
done

# If there are no arguments, we want to keep the container running,
# so the tmux session doesn't exit
# Otherwise, we want to execute the command passed through docker
if [ $# = 0 ]; then
    tail -f $WORKDIR/logs/latest.log
else
    # execute the command passed through docker
    exec "$@"
fi
