# Bottle

A shell script to compress and encrypt (and decrypt and extract) directories using [age](https://github.com/FiloSottile/age), [Zstandard compression](https://facebook.github.io/zstd/), and tar. At this point in time, this is **a toy project**, and **should not be used with sensitive and/or irreplaceable data/information!**

Bottle has no configuration options and a limited number of optional flags, in an attempt to follow age's philosophy of simplicity.

## What is this tool for?

Bottle is basically a wrapper around `age` to make the command even more user-friendly, especially for encrypting/decrypting directories. The use-case I wrote it for is backing up a small folder of about a dozen sensitive files (that rarely change) to Dropbox for my future self. In that way, it can be thought of a safe way to upload files to a cloud.

I would **NOT** recommend Bottle for backing up large amounts of data across multiple directories (like your enter User directory). For that, I'd recommend something like [Restic](https://restic.net/).

## Installation

### Prerequisites
1. [Install age](https://github.com/FiloSottile/age#installation). Bottle requires age version 1.0+. The related `age-keygen`, which you'll also need, should be included with that install (check with `age-keygen --version` -- it should also be 1.0 or later).
2. To use Bottle on directories, you'll need [tar](https://www.gnu.org/software/tar/) version 1.32 or higher available (run `tar --version` to check).

### Install Bottle
1. Clone down this Git repository.
2. Install `bottle` tool and create a new age key-pair, or "Identity", (if one does not exist) by running `./install.sh` (may need to run `chmod a+x install.sh` first). If you want to upgrade Bottle, follow this same procedure.

## Which age key does Bottle use?
By default, Bottle uses the age key at `~/.bottle/bottle_key.txt`. User can use an age key at a different location by using the `-k` flag.

## Uninstalling Bottle

Delete the Bottle script by running this:

```bash
sh -c 'rm "$(which bottle)"'
```

Note that deleting your age key means you won't be able to decrypt any files or directories you encrypted with Bottle, so be cautious!

## Usage

```text
USAGE:
    bottle [FLAGS] [Target]
    [Target] can be a directory or file to encrypt
    or a .age file to decrypt.
    If given a .tar.age, .tar.zst.age, or .tar.gz.age file, bottle will decrypt and extract contents.

FLAGS:
    -n     Do not use compression when encrypting a directory. By default, Bottle compresses directories before encrypting them.
    -t     If encrypting a file or directory, add timestamp to filename. Format is RFC3339.
    -k     Set location of age key file for bottle to use (defaults to ~/.bottle/bottle_key.txt)
    -f     Force overwrite of output file or directory, if it exists
    -l     Print the location of the key of the age identity that Bottle uses
    -p     Print the public key of the age identity that Bottle uses
    -P     Print location and public key of the age identity that Bottle uses
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
    Compress and encrypt a directory with age key file in non-default location:
        bottle -k <path/to/age-identity-file> <path/to/directory-to-bottle>
    Encrypt a directory without compressing:
        bottle -n <path/to/directory-to-bottle>
    Compress and encrypt directory, over-writing existing encrypted directory:
        bottle -f <path/to/directory-to-bottle>
    Compress and encrypt directory and add timestamp to resulting file name:
        bottle -t <path/to/directory-to-bottle>
```

Note that Bottle will always create the outputted file **in the current working directory**. It will be named automatically based on the inputted file.

## Compression

If Bottle is given a directory to "bottle", by default Bottle:
1. Collects it into a single tar file;
2. Compresses it with [Zstandard compression](https://facebook.github.io/zstd/);
3. Encrypts that resulting file with age.

Optionally, you can tell Bottle NOT to compress a given directory with the `-n` flag. This will create a file with the extension `.tar.age` (which Bottle can "unbottle").

If given a single, unencrypted file to encrypt, Bottle will NOT use compression before encrypting the file. Bottle will simply encrypt it with age.

### Zstandard

[Zstandard compression](https://facebook.github.io/zstd) is "a fast compression algorithm, providing high compression ratios" made by Meta/Facebook. It was open-sourced in 2016. I think it's a good balance between compression/decompression speed and compression ratio. Bottle uses the default compression level of 3 out of 19, meaning it prioritizes speed over compression ratio.

### "Bringing your own" compression tool

If you do want to "bring your own" compression tool, or pass an argument to `zstd`, you can run something like this:

```bash
tar -c -C directory-to-archive . | zstd -10 | age --encrypt -i ~/.bottle/bottle_key.txt > directory-to-archive.tar.zst.age
```

or you can put it in the `tar` command:

```bash
tar -I "zstd -10" -c -C directory-to-archive . | age --encrypt -i ~/.bottle/bottle_key.txt > directory-to-archive.tar.zst.age
```

or use [bzip2](https://en.wikipedia.org/wiki/Bzip2), as an example:

```bash
tar -I "bzip2 -2" -c -C directory-to-archive . | age --encrypt -i ~/.bottle/bottle_key.txt > directory-to-archive.tar.bzip2.age
```

### Unbottling GZipped files

Note that Bottle can "unbottle," or extract, directories that are compressed with gzip (with file extension .tar.gz.age), as well as uncompressed bottled directories (file extension .tar.age). You don't need to add any flags, just run `bottle archive.tar.gz.age`

Similarly, Bottle can unbottle uncompressed .tar.age files: `bottle archive.tar.age`.

## Un-Bottling an encrypted file without Bottle script (Troubleshooting)

Let's say you have a `.tar.zst.age` file (or `.tar.gz.age` file) that you, at once point, encrypted with Bottle, but now you can't install or get the `bottle` tool to work. Here's a procedure for decrypting and extracting such a file _without_ using Bottle (though you still need the `bottle_key.txt` file you used to encrypt the file/directory).

With [age installed](https://github.com/FiloSottile/age#installation), try the following three commands to decrypt and extract your Bottled directory:

```bash
age --decrypt -i ~/.bottle/bottle_key.txt my_archive.tar.zst.age > compressed_decrypted_archive.tar.zst
mkdir my_archive
tar -xf compressed_decrypted_archive.tar.zst -C ./my_archive
```

## Note on the name of this project

This project is not affiliated with the similarly named [bitbottle](https://code.lag.net/robey/bitbottle) project, nor are the archive file formats compatible, to my knowledge. That said, it looks much more sophisticated than my tool, so it might fit your needs better. Also, sorry about the name conflict... worried I subconsciously copied it. Open an issue if you have a suggestion for a new name for this project!

## To do

- [X] Ability to print (public) key of key-pair at `~/.bottle/bottle_key.txt`
- [ ] Resolve errors flagged by [shellcheck.net](https://www.shellcheck.net/)
- [ ] Ability to encrypt a directory with only access to a public key. (Looks like I would use age's `-R` flag.)
- [ ] An option to use your ssh key instead ([which age supports](https://github.com/FiloSottile/age#ssh-keys))

## Rust port

I'm working on [a Rust port of Bottle](https://github.com/sts10/bottle-rs/), however its current version [handles memory poorly](https://github.com/sts10/bottle-rs/issues/1).
