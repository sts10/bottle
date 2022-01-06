#!/bin/bash
KEYFILE=/home/$USER/age/archive.txt

# Check that keyfile exists
if [ ! -f "$KEYFILE" ]; then
  echo "$KEYFILE does not exist."
  echo "Creating an age key-pair for bottle to use by running:"
  echo "mkdir ~/age && age-keygen -o ~/age/archive.txt"
  exit 1
fi
if [ "$1" == "pop" ]
then
  if [ -z "$2" ]
    then
      echo "No target supplied. Run bottle help for help."
      exit 1
  fi
  OUTPUTDIR="$(basename "${2}" .tar.gz.age)"
  mkdir $OUTPUTDIR
  age --decrypt -i $KEYFILE "$2" | tar -xzP -C $OUTPUTDIR
elif [ "$1" == "cork" ]
then
  if [ -z "$2" ]
    then
      echo "No target supplied. Run bottle help for help."
      exit 1
  fi
  OUTPUTDIR="$(dirname .)"
  OUTPUTDEST="$(basename "${2}")"
  tar -cz -C "$2" $OUTPUTDIR --absolute-names "$2" | age --encrypt -i $KEYFILE > $OUTPUTDEST.tar.gz.age
else
  echo "bottle HELP"
  echo ""
  echo "Compress and encrypt directories with:"
  echo "    bottle cork <path/to/directory>"
  echo "Extract and decrypt directories with:"
  echo "    bottle pop <path/to/file>.tar.gz.age"
fi
