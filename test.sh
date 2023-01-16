#!/bin/bash

cd practice
# reset test files
rm -rf folder && rm folder.* && mkdir folder && touch folder/test_file.txt
# Do a simple encryption
../bottle.sh folder
rm -rf folder && ../bottle.sh folder.tar.zst.age && ls folder && rm folder.tar.zst.age && ../bottle.sh folder
rm -rf folder && ../bottle.sh folder.tar.zst.age && ls folder && rm folder.tar.zst.age && ../bottle.sh folder
echo "Made it through a basic test."
cd ..
