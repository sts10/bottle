#!/bin/bash

# Get the invoking command to display in help text
PROGRAM="${0##*/}"
# Hard-code the age key identity file
KEYFILE=$HOME/.bottle/bottle_key.txt
# This variable of whether the user wants to print a timestamp in encrypted output.
# defaults to 0 (no)
TIMESTAMPEDWANTED=0
OVERWRITEALLOWED=0
while getopts "thpkfln" option; do
        case ${option} in
        p)
                # Print public key and exit
                age-keygen -y "$KEYFILE"
                exit 0
                ;;
        l)
                # Print location of age identity file and exit
                echo "$KEYFILE"
                exit 0
                ;;
        k)
                # Print key info all together and exit
                echo "Age key file location:"
                echo "$KEYFILE"
                echo "The public key of that identity is:"
                age-keygen -y "$KEYFILE"
                exit 0
                ;;
        h)
                echo "bottle"
                echo "Archive files and directories using age encryption, Zstandard, and tar"
                echo ""
                echo "USAGE:"
                echo "    $PROGRAM [FLAGS] [Target]"
                echo "    [Target] can be a directory or file to encrypt"
                echo "    or a .age file to decrypt."
                echo "    If given a .tar.age, .tar.zst.age, or .tar.gz.age file, bottle will decrypt and extract contents."
                echo ""
                echo "FLAGS:"
                echo "    -n     Do not use compression when encrypting a directory. By default, Bottle compresses directories before encrypting them."
                echo "    -t     If encrypting a file or directory, add timestamp to filename. Format is rfc3339."
                echo "    -f     Force overwrite of output file or directory, if it exists"
                echo "    -l     Print the location of the key of the age identity that Bottle uses"
                echo "    -p     Print the public key of the age identity that Bottle uses"
                echo "    -k     Print location and public key of the age identity that Bottle uses"
                echo "    -h     Print this help text"
                echo ""
                echo "EXAMPLES:"
                echo "    Encrypt a file:"
                echo "        $PROGRAM <path/to/file-to-bottle>"
                echo "    Decrypt a file:"
                echo "        $PROGRAM <path/to/file.age>"
                echo "    Compress and encrypt a directory:"
                echo "        $PROGRAM <path/to/directory-to-bottle>"
                echo "    Decrypt, decompress and extract directory:"
                echo "        $PROGRAM <path/to/file>.tar.zst.age"
                echo "    Encrypt a directory without compressing:"
                echo "        $PROGRAM -n <path/to/directory-to-bottle>"
                echo "    Compress and encrypt directory, over-writing existing encrypted directory:"
                echo "        $PROGRAM -f <path/to/directory-to-bottle>"
                echo "    Compress and encrypt directory and add timestamp to resulting file name:"
                echo "        $PROGRAM -t <path/to/directory-to-bottle>"
                exit 0
                ;;
        t)
                # User gave a t flag, so flip this variable for later use
                TIMESTAMPEDWANTED=1
                ;;
        f)
                # User gave a f flag, so flip this variable for later use
                OVERWRITEALLOWED=1
                ;;
        n)
                # User gave a n flag, so flip this variable for later use
                NOCOMPRESSION=1
                ;;
        *)
                echo "Unknown option/flag found. Run $PROGRAM -h for help."
                exit 1
        esac
done

# echo "Before - variable one is: $1"
# from https://www.howtogeek.com/778410/how-to-use-getopts-to-parse-linux-shell-script-options/#mixing-options-and-paramters
shift "$(($OPTIND -1))"
# echo "After - variable one is: $1"
# echo "The rest of the arguments (operands)"

# Check that keyfile exists
if [ ! -f "$KEYFILE" ]; then
        echo "$KEYFILE does not exist."
        echo "You can create an age key-pair for bottle to use by running:"
        echo "mkdir ~/.bottle && age-keygen -o ~/.bottle/bottle_key.txt"
        exit 1
fi

if [ -z "$1" ]; then
        echo "No target supplied. Run $PROGRAM -h for help."
        exit 1
fi

if [[ "$1" = "." ]]; then
        echo "Can't run on current working directory. Run $PROGRAM -h for help."
        exit 1
fi

if [ ! -z "$2" ]; then
        echo "Too many parameters given."
        echo "$PROGRAM only accepts one parameter."
        echo "If you wish to bottle more than one file, put them in a directory first. Then call $PROGRAM on that directory."
        exit 1
fi

if [[ $1 == *.tar.*.age ]]; then
        # If given a compressed, encryped tar file,
        # decrypt and extract it to current working directory
        fullfile=$1
        filename=$(basename -- "$fullfile")
        extension="${filename#*.}"
        dirnameToExtractTo="${filename%%.*}"
        if [ ! -f "$dirnameToExtractTo" ] && [ ! -d "$dirnameToExtractTo" ]; then
                case $extension in
                        tar.zst.age)
                                compressionflag="--zstd"
                                ;;
                        tar.gz.age)
                                compressionflag="-z"
                                ;;
                        tar.bzip2.age | tar.bz2.age )
                                compressionflag="-j"
                                ;;
                        tar.xz.age)
                                compressionflag="-J"
                                ;;
                        *)
                                echo "Unknown compression file extention $extension found. Unable to unbottle."
                                exit 1
                                ;;
                esac
                mkdir "$dirnameToExtractTo"
                age --decrypt -i "$KEYFILE" "$1" | tar -xP "$compressionflag" -C "$dirnameToExtractTo"
        else
                echo "Would create and decrypt to destination '$dirnameToExtractTo', but it already exists. Delete or rename existing directory or file, then run $PROGRAM again."
        fi
elif [[ $1 == *.tar.age ]]; then
        # If given an encrypted, UNCOMPRESSED tar file,
        # decrypt and extract it to current working directory
        OUTPUTDIR="$(basename "${1}" .tar.age)"
        if [ ! -f "$OUTPUTDIR" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                mkdir "$OUTPUTDIR"
                age --decrypt -i "$KEYFILE" "$1" | tar -xP -C "$OUTPUTDIR"
        else
                echo "Would create and decrypt to $OUTPUTDIR, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTDIR."
        fi
elif [[ $1 == *.age ]]; then
        # If given a simple age file, 
        # (attempt to) decrypt it with KEYFILE to current working directory
        OUTPUTFILE="$(basename "${1}" .age)"
        if [ ! -f "$OUTPUTFILE" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                age --decrypt -i "$KEYFILE" "$1" >"$OUTPUTFILE"
        else
                echo "Would decrypt to $OUTPUTFILE, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTFILE."
        fi
elif [[ -f "$1" ]]; then
        # If given a file that doesn't have a .age extension,
        # assume it's not encrypted and user wants to encrypt it with $KEYFILE.
        if [ "$TIMESTAMPEDWANTED" == 1 ]; then
                # Got a t flag, so we'll create a timestamp as a string
                TS="$(date --rfc-3339=seconds)"
                TSR="${TS//:/_}"
                STAMP="__bottled_${TSR// /-}"
        else
                # Didn't get a t flag, so we'll make STAMP an empty string
                STAMP=""
        fi
        OUTPUTFILE="$1""$STAMP".age
        if [ ! -f "$OUTPUTFILE" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                age --encrypt -i "$KEYFILE" "$1" >"$OUTPUTFILE"
        else
                echo "Would encrypt to $OUTPUTFILE, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTFILE."
        fi
elif [[ -d "$1" ]]; then
        # If given a plain directory...
        # compress and encrypt it to current working directory
        OUTPUTDIR="$(dirname .)"
        OUTPUTDEST="$(basename "${1}")"
        if [ "$TIMESTAMPEDWANTED" == 1 ]; then
                # Got a t flag, so we'll write a timestamp
                TS="$(date --rfc-3339=seconds)"
                TSR="${TS//:/_}"
                STAMP="__bottled_${TSR// /-}"
        else
                # Didn't get a t flag, so we'll make STAMP
                # an empty string
                STAMP=""
        fi
        if [ "$NOCOMPRESSION" == 1 ]; then
                # User does NOT want to compress directory when creating tar file
                OUTPUTFILE="$OUTPUTDEST""$STAMP".tar.age
                if [ ! -f "$OUTPUTFILE" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                        tar -c -C "$1" "$OUTPUTDIR" | age --encrypt -i "$KEYFILE" >"$OUTPUTFILE"
                else
                        echo "Would encrypt to $OUTPUTFILE, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTFILE."
                fi
        else
                # User DOES want to compress directory while making tar file
                # We'll use Zstandard compression algorithm
                OUTPUTFILE="$OUTPUTDEST""$STAMP".tar.zst.age
                if [ ! -f "$OUTPUTFILE" ] || [ "$OVERWRITEALLOWED" == 1 ]; then
                        tar -c --zstd -C "$1" "$OUTPUTDIR" | age --encrypt -i "$KEYFILE" >"$OUTPUTFILE"
                else
                        echo "Would encrypt to $OUTPUTFILE, but it already exists. Re-run with -f flag (force) to overwrite $OUTPUTFILE."
                fi
        fi
else
        echo "Inputted file or directory not found."
        echo "run $PROGRAM -h for help"
fi
