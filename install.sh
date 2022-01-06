echo "Installing bottle tool"
cp -v bottle.sh /home/$USER/.local/bin/bottle

KEYFILE=/home/$USER/age/archive.txt
if [ -f "$KEYFILE" ]; then
    echo "You already have a key at $KEYFILE"
    echo "bottle will use this key."
else 
    echo "$KEYFILE does not exist."
    echo "Creating an age key-pair for bottle to use at $KEYFILE"
    mkdir ~/age && age-keygen -o ~/age/archive.txt
fi
