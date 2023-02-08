#!/bin/bash
# "Unofficial BASH strcit mode" settings
# (from http://redsymbol.net/articles/unofficial-bash-strict-mode/)
set -euo pipefail
IFS=$'\n\t'

echo "Copying bottle tool to .local/bin/bottle"
cp -v bottle.sh $HOME/.local/bin/bottle

echo "Bottle installation complete."
echo "Run bottle -h for help."
