#!/bin/bash
if [ "$1" == "pop" ]
then
  if [ -z "$2" ]
    then
      echo "No target supplied."
      # return 1
      exit 1
  fi
  # age --decrypt -i ~/age/archive.txt "$1" | tar -xvz
  OUTPUTDIR="$(basename "${2}" .tar.gz.age)"
  mkdir $OUTPUTDIR
  # age --decrypt -i ~/age/archive.txt "$1" | tar -xz -C $OUTPUTDIR
  age --decrypt -i ~/age/archive.txt "$2" | tar -xzP -C $OUTPUTDIR
elif [ "$1" == "cork" ]
then
  if [ -z "$2" ]
    then
      echo "No target supplied."
      exit 1
  fi
  # INPUTDIR="$(dirname "${2}")"
  OUTPUTDIR="$(dirname .)"
  OUTPUTDEST="$(basename "${2}")"
  # OUTPUTBASENAME="$(basename "${2}")"
  tar -cz -C "$2" $OUTPUTDIR --absolute-names "$2" | age --encrypt -i ~/age/archive.txt > $OUTPUTDEST.tar.gz.age
else
  echo "bottle HELP"
  echo "Compress and encrypt directories with: bottle cork <path/to/filename>"
  echo "Extract and decrypt directories with: bottle pop <new_dir_name>"
fi
