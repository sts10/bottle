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
fi
if [ "$1" == "cork" ]
then
  INPUTDIR="$(dirname "${2}")"
  OUTPUTDIR="$(dirname .)"
  OUTPUTDEST="$(basename "${2}")"
  # OUTPUTBASENAME="$(basename "${2}")"
  tar -cz -C "$2" $OUTPUTDIR --absolute-names "$2" | age --encrypt -i ~/age/archive.txt > $OUTPUTDEST.tar.gz.age
fi
