#!/bin/bash

cd practice
rm -rf folder && ../bottle.sh folder.tar.zst.age && ls folder && rm folder.tar.zst.age && ../bottle.sh folder
rm -rf folder && ../bottle.sh folder.tar.zst.age && ls folder && rm folder.tar.zst.age && ../bottle.sh folder
echo "Made it through a basic test."
cd ..
