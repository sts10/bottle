# Bottle

A shell script to compress and encrypt (and decrypt and extract) directories using [age](https://github.com/FiloSottile/age) and tar.

## Installation 

1. [Install age](https://github.com/FiloSottile/age#installation). age-keygen should be included with that install (check with `age-keygen --version`).
2. Clone down this repository.
3. Install `bottle` tool and create an age key-pair (if one does not exist) by running `./install.sh` (may need to run `chmod a+x install.sh` first)

`bottle` will only ever use the age key-pair located at `~/age/archive.txt` (unless you edit the `bottle.sh` shell script).

## Usage

Compress and encrypt a directory with `bottle cork path/to/directory`.

Decrypt and extract an archive file (should have a `.tar.gz.age` file extension) with `bottle pop path/to/archive.tar.gz.age`.

Get help with `bottle help`.

## To do

- [ ] Create a key at `~/age/bottle.key` if there isn't one already
- [ ] Ability to "cork" with only access to a public key. (Looks like I would use age's `-R` flag.)
- [ ] Ability to print (public) key at `~/age/bottle.key`
- [ ] An option to use your ssh key instead ([which age supports](https://github.com/FiloSottile/age#ssh-keys))

Also: Should I (re-)write this in Go or Rust?
