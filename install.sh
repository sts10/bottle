echo "Installing bottle tool"
cp -v bottle.sh $HOME/.local/bin/bottle

KEYFILE=$HOME/.bottle/bottle_key.txt
if [ -f "$KEYFILE" ]; then
	echo "You already have a Age Identity at $KEYFILE"
	echo "Bottle will use this Identity."
else
	echo "$KEYFILE does not exist."
	echo "Creating an Age Identity for Bottle to use at $KEYFILE"
	mkdir ~/.bottle && age-keygen -o ~/.bottle/bottle_key.txt
fi
