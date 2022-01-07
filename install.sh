echo "Installing bottle tool"
cp -v bottle.sh $HOME/.local/bin/bottle

KEYFILE=$HOME/age/archive.txt
if [ -f "$KEYFILE" ]; then
	echo "You already have a key at $KEYFILE"
	echo "Bottle will use this key."
else
	echo "$KEYFILE does not exist."
	echo "Creating an age key-pair for Bottle to use at $KEYFILE"
	mkdir ~/age && age-keygen -o ~/age/archive.txt
fi
