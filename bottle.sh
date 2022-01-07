#!/bin/bash
KEYFILE=$HOME/age/archive.txt

# Check that keyfile exists
if [ ! -f "$KEYFILE" ]; then
	echo "$KEYFILE does not exist."
	echo "You can create an age key-pair for bottle to use by running:"
	echo "mkdir ~/age && age-keygen -o ~/age/archive.txt"
	exit 1
fi

if [ -z "$1" ]; then
	echo "No target supplied. Run bottle --help for help."
	exit 1
fi

if [[ "$1" = "." ]]; then
	echo "Can't run on current working directory. Run bottle --help for help."
	exit 1
fi

if [ ! -z "$2" ]; then
	echo "Too many parameters given."
	echo "bottle only accepts one parameter."
	echo "If you wish to bottle more than one file, put them in a directory first. Then call bottle on that directory."
fi

# if given a specific archive-type file,
# decrypt and extract it to current working directory
if [[ $1 == *.tar.gz.age ]]; then
	OUTPUTDIR="$(basename "${1}" .tar.gz.age)"
	mkdir "$OUTPUTDIR"
	age --decrypt -i "$KEYFILE" "$1" | tar -xzP -C "$OUTPUTDIR"
elif [[ $1 == *.age ]]; then
	# If given a simple age file, (attempt to) decrypt it
	# with KEYFILE to current working directory
	OUTPUTFILE="$(basename "${1}" .age)"
	age --decrypt -i "$KEYFILE" "$1" >"$OUTPUTFILE"
elif [[ -f "$1" ]]; then
	# If given a file that doesn't have a .age extension,
	# encrypt it with $KEYFILE.
	age --encrypt -i "$KEYFILE" "$1" >"$1".age
elif [[ -d "$1" ]]; then
	# If given a directory...
	# compress and encrypt it to current working directory
	ABSOLUTEINPUT="$(realpath "${1}")"
	OUTPUTDIR="$(dirname .)"
	OUTPUTDEST="$(basename "${1}")"
	tar -cz -C "$1" "$OUTPUTDIR" --absolute-names "$ABSOLUTEINPUT" | age --encrypt -i "$KEYFILE" >"$OUTPUTDEST".tar.gz.age
elif [[ "$1" = "help" ]] || [[ "$1" = "--help" ]] || [[ "$1" = "-h" ]]; then

	echo "bottle"
	echo "Archive files and directories using age encryption and tar"
	echo ""
	echo "USAGE:"
	echo "    bottle [TARGET]"
	echo "    TARGET can be a directory or file to encrypt"
	echo "    or a .age file to decrypt."
	echo "    If given a .tar.gz.age file, bottle will decrypt and extract contents."
	echo ""
	echo "EXAMPLES:"
	echo "    Compress and encrypt directories:"
	echo "        bottle <path/to/directory-to-bottle>"
	echo "    Extract and decrypt directories:"
	echo "        bottle <path/to/file>.tar.gz.age"
else
	echo "Inputted file or directory not found."
	echo "run bottle --help for help"
fi
