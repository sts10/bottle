# Bottle

A shell script to compress and encrypt (and decrypt and extract) directories using [age](https://github.com/FiloSottile/age), zstd, and tar. At this point in time, this is **a toy project**, and **should not be used with sensitive and/or irreplaceable data/information!**

Bottle has no configuration options and a limited number of optional flags, in an attempt to follow age's philosophy of simplicity.

## What is this tool for? 

Bottle is basically a wrapper around `age` to make the command even more user-friendly, especially for encrypting/decrypting directories. The use-case I wrote it for is backing up a small folder of about a dozen sensitive files (that rarely change) to Dropbox. 

I would **NOT** recommend Bottle for backing up large amounts of data across multiple directories (like your enter User directory). For that, I'd recommend something like [restic](https://restic.net/).

## Installation 

### Prerequisites 
1. [Install age](https://github.com/FiloSottile/age#installation). Bottle requires age version 1.0+. The related `age-keygen`, which you'll also need, should be included with that install (check with `age-keygen --version` -- it should also be 1.0 or later).
2. To use Bottle on directories, you'll need [tar](https://www.gnu.org/software/tar/) version 1.32 or higher available (run `tar --version` to check).

### Install Bottle
1. Clone down this Git repository.
2. Install `bottle` tool and create a new age key-pair, or "Identity", (if one does not exist) by running `./install.sh` (may need to run `chmod a+x install.sh` first). If you want to upgrade Bottle, follow this same procedure.

## Which age key does Bottle use?
Bottle will only ever use the age key-pair located at `~/.bottle/bottle_key.txt` (unless you edit the `bottle.sh` shell script).

## Uninstalling Bottle

Delete the Bottle script by running this:

```bash
sh -c 'rm "$(which bottle)"'
```

The age key that Bottle uses should be located at `~/.bottle/bottle_key.txt`. Note that deleting this file means you won't be able to decrypt any files or directories you encrypted with Bottle, so be cautious!

## Usage

```text
USAGE:
    bottle [FLAGS] [Target]
    [Target] can be a directory or file to encrypt
    or a .age file to decrypt.
    If given a .tar.age, .tar.zst.age, or .tar.gz.age file, bottle will decrypt and extract contents.

FLAGS:
    -n     Do not use compression when encrypting a directory. By default, Bottle compresses directories before encrypting them.
    -t     If encrypting a file or directory, add timestamp to filename
    -f     Force overwrite of output file or directory, if it exists
    -l     Print the location of the key of the age identity that Bottle uses
    -p     Print the public key of the age identity that Bottle uses
    -k     Print location and public key of the age identity that Bottle uses
    -h     Print this help text

EXAMPLES:
    Encrypt a file:
        bottle <path/to/file-to-bottle>
    Decrypt a file:
        bottle <path/to/file.age>
    Compress and encrypt a directory:
        bottle <path/to/directory-to-bottle>
    Decrypt, decompress and extract directory:
        bottle <path/to/file>.tar.zst.age
    Encrypt a directory without compressing:
        bottle -n <path/to/directory-to-bottle>
    Compress and encrypt directory, over-writing existing encrypted directory:
        bottle.sh -f <path/to/directory-to-bottle>
    Compress and encrypt directory and add timestamp to resulting file name:
        bottle.sh -t <path/to/directory-to-bottle>
```

Note that Bottle will always create the outputted file **in the current working directory**. It will be named automatically based on the inputted file.

## Note on the name

This project is not affiliated with the similarly named [bitbottle](https://code.lag.net/robey/bitbottle) project, nor are the archive file formats compatible, to my knowledge. That said, it looks much more sophisticated than my tool, so it might fit your needs better. Also, sorry about the name conflict... worried I subconsciously copied it. Open an issue if you have a suggestion for a new name for this project!

## To do

- [X] Ability to print (public) key of key-pair at `~/.bottle/bottle_key.txt`
- [ ] Ability to encrypt a directory with only access to a public key. (Looks like I would use age's `-R` flag.)
- [ ] An option to use your ssh key instead ([which age supports](https://github.com/FiloSottile/age#ssh-keys))

## Rust port

I'm working on [a Rust port of Bottle](https://github.com/sts10/bottle-rs/), however its current version [handles memory poorly](https://github.com/sts10/bottle-rs/issues/1).
