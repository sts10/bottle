#!/bin/bash

echo "Installing bottle tool to ~/.local/bin/bottle"
cp -v bottle.sh $HOME/.local/bin/bottle

KEYFILE=$HOME/.bottle/bottle_key.txt
if [ -f "$KEYFILE" ]; then
        echo "You already have a Age Identity at $KEYFILE"
        echo "Bottle will use this Identity."
else
        echo "$KEYFILE does not exist."
        echo "Creating an Age Identity for Bottle to use at $KEYFILE"
        mkdir ~/.bottle && age-keygen -o ~/.bottle/bottle_key.txt
        echo "Done creating Age Identity"
fi
echo "Bottle installation complete."
echo "Run bottle -h for help."
