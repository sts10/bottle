# Bottle

A shell script to compress and encrypt (and decrypt and extract) directories using [age](https://github.com/FiloSottile/age) and tar. At this point in time, this is **a toy project**, and **should not be used with sensitive and/or irreplaceable data/information!**

Bottle has no config options and only takes a single parameter, in an attempt to follow age's philosophy of simplicity.

Note that I'm working on [a Rust port of Bottle](https://github.com/sts10/bottle-rs/).

## Installation 

1. [Install age](https://github.com/FiloSottile/age#installation). Bottle requires age version 1.0+. The related `age-keygen`, which you'll also need, should be included with that install (check with `age-keygen --version`).
2. Clone down this repository.
3. Install `bottle` tool and create an age key-pair (if one does not exist) by running `./install.sh` (may need to run `chmod a+x install.sh` first)

`bottle` will only ever use the age key-pair located at `~/.bottle/bottle_key.txt` (unless you edit the `bottle.sh` shell script).

### Uninstall Bottle

Delete the Bottle script by running this:

```bash
sh -c 'rm "$(which bottle)"'
```

The age key that Bottle uses should be located at `~/.bottle/bottle_key.txt`. Note that deleting this file means you won't be able to decrypt any files or directories you encrypted with Bottle, so be cautious!

## Usage

Bottle will always create the outputted file **in the current working directory**. It will be named automatically based on the inputted file.

- Encrypt a file with `bottle <path/to/file>`
- Compress and encrypt a directory with `bottle <path/to/directory>`. 
- Decrypt an age-encrypted file with `bottle <path/to/file>.age`
- Decrypt and extract a `.tar.gz.age` file with `bottle <path/to/archive>.tar.gz.age`.

If encrypting, you can add a tiemstamp into the filename with `-t` flag. Force output file overwrite with `-f`. Display key info with `-k`. 

For more help, run `bottle -h`.

## Note on the name

This project is not affiliated with the similarly named [bitbottle](https://code.lag.net/robey/bitbottle) project, nor are the archive file formats compatible, to my knowledge. That said, it looks much more sophisticated than my tool, so it might fit your needs better. Also, sorry about the name conflict... worried I subconsciously copied it. Open an issue if you have a suggestion for a new name for this project!

## To do

- [X] Ability to print (public) key of key-pair at `~/.bottle/bottle_key.txt`
- [ ] Ability to encrypt a directory with only access to a public key. (Looks like I would use age's `-R` flag.)
- [ ] An option to use your ssh key instead ([which age supports](https://github.com/FiloSottile/age#ssh-keys))

## Rust port

As noted above, I'm working on [a Rust port of Bottle](https://github.com/sts10/bottle-rs/), however its current version [handles memory poorly](https://github.com/sts10/bottle-rs/issues/1).
