# Bottle

A shell script to compress and encrypt (and decrypt and extract) directories using [age](https://github.com/FiloSottile/age) and tar.

## To do

Could add functionality to: 

- [ ] Create a key at `~/age/bottle.key`if there isn't one already
- [ ] Ability to "cork" with only access to a public key.
- [ ] Ability to print (public) key at `~/age/bottle.key`
- [ ] An option to use your ssh key instead (which age supports)

Also: Should I (re-)write this in Go or Rust?
