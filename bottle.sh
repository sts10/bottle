#!/bin/bash
KEYFILE=/home/$USER/age/archive.txt

# Check that keyfile exists
if [ ! -f "$KEYFILE" ]; then
  echo "$KEYFILE does not exist."
  echo "Creating an age key-pair for bottle to use by running:"
  echo "mkdir ~/age && age-keygen -o ~/age/archive.txt"
  exit 1
fi

# if given a specific archive-type file,
# decrypt and extract it to current working directory
if [[ $1 == *.tar.gz.age ]]
then
  if [ -z "$1" ]
    then
      echo "No target supplied. Run bottle help for help."
      exit 1
  fi
  OUTPUTDIR="$(basename "${1}" .tar.gz.age)"
  mkdir $OUTPUTDIR
  age --decrypt -i $KEYFILE "$1" | tar -xzP -C $OUTPUTDIR
elif [ -d "$1" ]
  # If given a directory...
  # compress and encrypt it to current working directory
then
  OUTPUTDIR="$(dirname .)"
  OUTPUTDEST="$(basename "${1}")"
  tar -cz -C "$1" $OUTPUTDIR --absolute-names "$1" | age --encrypt -i $KEYFILE > $OUTPUTDEST.tar.gz.age
else
  echo "bottle"
  echo ""
  echo "Compress and encrypt directories with:"
  echo "    bottle <path/to/directory-to-bottle>"
  echo "Extract and decrypt directories with:"
  echo "    bottle <path/to/file>.tar.gz.age"
fi
