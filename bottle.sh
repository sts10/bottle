#!/bin/bash
KEYFILE=/home/$USER/age/archive.txt

# Check that keyfile exists
if [ ! -f "$KEYFILE" ]; then
  echo "$KEYFILE does not exist."
  echo "You can create an age key-pair for bottle to use by running:"
  echo "mkdir ~/age && age-keygen -o ~/age/archive.txt"
  exit 1
fi

if [ -z "$1" ]
then
  echo "No target supplied. Run bottle help for help."
  exit 1
fi

# if given a specific archive-type file,
# decrypt and extract it to current working directory
if [[ $1 == *.tar.gz.age ]]
then
  OUTPUTDIR="$(basename "${1}" .tar.gz.age)"
  mkdir "$OUTPUTDIR"
  age --decrypt -i "$KEYFILE" "$1" | tar -xzP -C "$OUTPUTDIR"
elif [[ $1 == *.age ]]
then
  # If given a simple age file, (attempt to) decrypt it 
  # with KEYFILE to current working directory
  OUTPUTFILE="$(basename "${1}" .age)"
  age --decrypt -i "$KEYFILE" "$1" > "$OUTPUTFILE"
elif [[ -f "$1" ]]
then
  # If given a file that doesn't have a .age extension,
  # encrypt it with $KEYFILE.
  age --encrypt -i "$KEYFILE" "$1" > "$1".age
elif [[ -d "$1" ]]
then
  # If given a directory...
  # compress and encrypt it to current working directory
  ABSOLUTEINPUT="$(realpath "${1}")"
  OUTPUTDIR="$(dirname .)"
  OUTPUTDEST="$(basename "${1}")"
  tar -cz -C "$1" "$OUTPUTDIR" --absolute-names "$ABSOLUTEINPUT" | age --encrypt -i "$KEYFILE" > "$OUTPUTDEST".tar.gz.age
else
  echo "bottle"
  echo ""
  echo "Compress and encrypt directories with:"
  echo "    bottle <path/to/directory-to-bottle>"
  echo "Extract and decrypt directories with:"
  echo "    bottle <path/to/file>.tar.gz.age"
fi
