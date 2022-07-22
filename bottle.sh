#!/bin/bash

# Get the invoking command to display in help text
PROGRAM="${0##*/}"
# Hard-code the age key identity file
KEYFILE=$HOME/.bottle/bottle_key.txt
# This variable of whetehr the user wants to print
# a timestamp in encrypted output defaults to 0 (no)
TIMESTAMPEDWANTED=0
OVERWRITEALLOWED=0
while getopts "thpkfl" option; do
        case ${option} in
        p)
                # Print public key and exit
                age-keygen -y "$KEYFILE"
                exit 1
                shift
                ;;
        l)
                # Print location of age identity file and exit
                echo "$KEYFILE"
                exit 1
                shift
                ;;
        k)
                # Print key info all together and exit
                echo "Age key file location:"
                echo "$KEYFILE"
                echo "The public key of that identity is:"
                # age-keygen -y "$KEYFILE"
                echo "$(age-keygen -y "$KEYFILE")"
                exit 1
                shift
                ;;
        h)
                echo "bottle"
                echo "Archive files and directories using age encryption, gzip, and tar"
                echo ""
                echo "USAGE:"
                echo "    $PROGRAM [FLAGS] [Target]"
                echo "    [Target] can be a directory or file to encrypt"
                echo "    or a .age file to decrypt."
                echo "    If given a .tar.gz.age file, bottle will decrypt and extract contents."
                echo ""
                echo "FLAGS:"
                echo "    -l     Print the location of the key of the age identity that Bottle uses"
                echo "    -p     Print the public key of the age identity that Bottle uses"
                echo "    -k     Print location and public key of the age identity that Bottle uses"
                echo "    -f     Force overwrite of output file or directory, if it exists"
                echo "    -t     If encrypting a file or directory, add timestamp to filename"
                echo ""
                echo "EXAMPLES:"
                echo "    Encrypt a file:"
                echo "        $PROGRAM <path/to/file-to-bottle>"
                echo "    Decrypt a file:"
                echo "        $PROGRAM <path/to/file.age>"
                echo "    Compress and encrypt a directory:"
                echo "        $PROGRAM <path/to/directory-to-bottle>"
                echo "    Extract and decrypt directories:"
                echo "        $PROGRAM <path/to/file>.tar.gz.age"
                echo "    Compress and encrypt file with timestamp:"
                echo "        $PROGRAM -t <path/to/directory-to-bottle>"
                exit 1
                shift
                ;;
        t)
                # User gave a t flag, so flip this variable
                # for later use
                TIMESTAMPEDWANTED=1
                shift
                ;;
        f)
                # User gave a f flag, so flip this variable
                # for later use
                OVERWRITEALLOWED=1
                shift
                ;;
        esac
done

# Check that keyfile exists
if [ ! -f "$KEYFILE" ]; then
        echo "$KEYFILE does not exist."
        echo "You can create an age key-pair for bottle to use by running:"
        echo "mkdir ~/.bottle && age-keygen -o ~/.bottle/bottle_key.txt"
        exit 1
fi

if [ -z "$1" ]; then
        echo "No target supplied. Run $PROGRAM --help for help."
        exit 0
fi

if [[ "$1" = "." ]]; then
        echo "Can't run on current working directory. Run $PROGRAM --help for help."
        exit 0
fi

if [ ! -z "$2" ]; then
        echo "Too many parameters given."
        echo "bottle only accepts one parameter."
        echo "If you wish to bottle more than one file, put them in a directory first. Then call bottle on that directory."
        exit 0
fi

# If given a specific archive-type file,
# decrypt and extract it to current working directory
if [[ $1 == *.tar.gz.age ]]; then
        OUTPUTDIR="$(basename "${1}" .tar.gz.age)"
        if [ ! -f "$OUTPUTDIR" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                mkdir "$OUTPUTDIR"
                age --decrypt -i "$KEYFILE" "$1" | tar -xzP -C "$OUTPUTDIR"
        else
                echo "Would create and decrypt to $OUTPUTDIR, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTDIR."
        fi
elif [[ $1 == *.age ]]; then
        # If given a simple age file, (attempt to) decrypt it
        # with KEYFILE to current working directory
        OUTPUTFILE="$(basename "${1}" .age)"
        if [ ! -f "$OUTPUTFILE" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                age --decrypt -i "$KEYFILE" "$1" >"$OUTPUTFILE"
        else
                echo "Would decrypt to $OUTPUTFILE, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTFILE."
        fi
elif [[ -f "$1" ]]; then
        # If given a file that doesn't have a .age extension,
        # encrypt it with $KEYFILE.
        if [ "$TIMESTAMPEDWANTED" == 1 ]; then
                # Got a t flag, so we'll write a timestamp
                TS="$(date --rfc-3339=seconds)"
                TSR="$(echo "${TS//:/_}")"
                STAMP="$(echo "__bottled_${TSR// /-}")"
        else
                # Didn't get a t flag, so we'll make STAMP
                # an empty string
                STAMP=""
        fi
        OUTPUTFILE="$1""$STAMP".age
        if [ ! -f "$OUTPUTFILE" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                age --encrypt -i "$KEYFILE" "$1" >"$OUTPUTFILE"
        else
                echo "Would encrypt to $OUTPUTFILE, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTFILE."
        fi
elif [[ -d "$1" ]]; then
        # If given a directory...
        # compress and encrypt it to current working directory
        OUTPUTDIR="$(dirname .)"
        OUTPUTDEST="$(basename "${1}")"
        if [ "$TIMESTAMPEDWANTED" == 1 ]; then
                # Got a t flag, so we'll write a timestamp
                TS="$(date --rfc-3339=seconds)"
                TSR="$(echo "${TS//:/_}")"
                STAMP="$(echo "__bottled_${TSR// /-}")"
        else
                # Didn't get a t flag, so we'll make STAMP
                # an empty string
                STAMP=""
        fi
        OUTPUTFILE="$OUTPUTDEST""$STAMP".tar.gz.age
        if [ ! -f "$OUTPUTFILE" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                tar -cz -C "$1" "$OUTPUTDIR" | age --encrypt -i "$KEYFILE" >"$OUTPUTFILE"
        else
                echo "Would encrypt to $OUTPUTFILE, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTFILE."
        fi
else
        echo "Inputted file or directory not found."
        echo "run $PROGRAM -h for help"
fi
