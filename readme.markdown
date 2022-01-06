# Bottle

A shell script to compress and encrypt (and decrypt and extract) directories using [age](https://github.com/FiloSottile/age) and tar. 

Bottle has no config options and only takes a single parameter, in an attempt to follow age's philosophy of simplicity.

## Installation 

1. [Install age](https://github.com/FiloSottile/age#installation). age-keygen should be included with that install (check with `age-keygen --version`).
2. Clone down this repository.
3. Install `bottle` tool and create an age key-pair (if one does not exist) by running `./install.sh` (may need to run `chmod a+x install.sh` first)

`bottle` will only ever use the age key-pair located at `~/age/archive.txt` (unless you edit the `bottle.sh` shell script).

## Usage

Bottle will always create the outputted file **in the current working directory**. It will be named automatically based on the inputted file.

- Encrypt a file with `bottle <path/to/file>`
- Compress and encrypt a directory with `bottle <path/to/directory>`. 
- Decrypt an age-encrypted file with `bottle <path/to/file>.age`
- Decrypt and extract a `.tar.gz.age` file with `bottle <path/to/archive>.tar.gz.age`.

Get help with `bottle help`.

## To do

- [ ] Ability to encrypt a directory with only access to a public key. (Looks like I would use age's `-R` flag.)
- [ ] Ability to print (public) key of key-pair at `~/age/bottle.key`
- [ ] An option to use your ssh key instead ([which age supports](https://github.com/FiloSottile/age#ssh-keys))

Also: Should I (re-)write this in Go or Rust?
