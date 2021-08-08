# Pencoder

> Yet another powerful **p**ayload **encoder** powered by Bash

## Table of Contents

- [Features](#features)
- [Supported encoders](#supported-encoders)
- [Download](#download)
- [Usage](#usage)
- [Examples](#examples)
  - [Encoding with one encoder](#encoding-with-one-encoder)
  - [Decoding with one decoder](#decoding-with-one-decoder)
  - [Encoding with multiple encoders](#encoding-with-multiple-encoders)
  - [Decoding with multiple decoders](#decoding-with-multiple-decoders)
  - [Running the same encoder multiple times](#running-the-same-encoder-multiple-times)
  - [Working with pipe](#working-with-pipe)

## Features

- Single Bash script
- No 3rd-party dependency
- Support different kinds of encoders/decoders
- Apply multiple encodings at once as a chain

## Supported encoders

- Base32 encode/decode
- Base64 encode/decode
- Hex encode using \x delimiter
- Hex encode/decode
- URL encode/decode
- Unicode encode using \u delimiter /decode
- HTML encode/decode
- Morse encode/decode
- 8-bit binary encode/decode
- Rot13 encode/decode

## Download

```bash
$ wget https://raw.githubusercontent.com/KevCui/pencoder/master/pencoder.sh
$ chmod +x pencoder.sh
```

## Usage

```
Usage:
  ./pencoder.sh [encoder1] [encoder2] ... <string>

Options:
  string           input string
  encoder          b32:     base32 encode
                   b32de:   base32 decode
                   b64:     base64 encode
                   b64de:   base64 decode
                   bin:     8-bit binary encode
                   binde:   8-bit binary decode
                   hex:     hex encode
                   xhex:    hex encode using \x delimiter
                   hexde:   hex decode
                   url:     URL encode
                   urlde:   URL decode
                   uni:     Unicode encode using \u delimiter
                   unide:   Unicode decode
                   html:    HTML encode
                   htmlde:  HTML decode
                   morse:   Morse encode
                   morsede: Morse decode
                   rot13:   Rot13 encode
                   rot13de: Rot13 decode
                   support multiple encoders: encoder1 encoder2...
  -h | --help      display this help message
```

## Examples

### Encoding with one encoder

```bash
$ ./pencoder.sh b64 'this is a test'
dGhpcyBpcyBhIHRlc3Q=
```

```bash
$ ./pencoder.sh morse sos
... --- ...
```

```bash
$ ./pencoder.sh bin Xmas
01011000 01101101 01100001 01110011
```

### Decoding with one decoder

```bash
$ ./pencoder.sh b64de 'dGhpcyBpcyBhIHRlc3Q='
this is a test
```

```bash
$ ./pencoder.sh morsede '... --- ...'
SOS
```

```bash
$ ./pencoder.sh binde '01001101 01100001 01110100 01110100 01100101 00100000 01000010 01101100 01100001 01100011 01101011 00100000 01000101 01110110 01100101 01110010 01111001 01110100 01101000 01101001 01101110 01100111 00101110'
Matte Black Everything.
```

### Encoding with multiple encoders

```bash
$ ./pencoder.sh url b64 hex 'crazy encoding'
59334a68656e6b6c4d6a426c626d4e765a476c755a773d3d
```

### Decoding with multiple decoders

```bash
$ ./pencoder.sh hexde b64de urlde '59334a68656e6b6c4d6a426c626d4e765a476c755a773d3d'
crazy encoding
```

### Running the same encoder multiple times

```bash
$ ./pencoder.sh b64 b64 b64 'xyz'
WlVoc05nPT0=
```

### Working with pipe

```bash
$ echo "super mario" | xargs -0 ./pencoder.sh url b64 hex
633356775a58496c4d6a427459584a7062773d3d
```

---

<a href="https://www.buymeacoffee.com/kevcui" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-orange.png" alt="Buy Me A Coffee" height="60px" width="217px"></a>
