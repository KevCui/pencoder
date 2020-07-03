#!/usr/bin/env bash
#
# Powerful payload encoder powered by Bash
#
#/ Usage:
#/   ./pencoder.sh [encoder1] [encoder2] ... <string>
#/
#/ Options:
#/   string           input string
#/   encoder          \033[32mb32\033[0m:    base32 encode
#/                    \033[32mb32de\033[0m:  base32 decode
#/                    \033[32mb64\033[0m:    base64 encode
#/                    \033[32mb64de\033[0m:  base64 decode
#/                    \033[32mhex\033[0m:    hex encode
#/                    \033[32mxhex\033[0m:   hex encode using \\x delimiter
#/                    \033[32mhexde\033[0m:  hex decode
#/                    \033[32murl\033[0m:    URL encode
#/                    \033[32murlde\033[0m:  URL decode
#/                    \033[32muni\033[0m:    Unicode encode using \\u delimiter
#/                    \033[32munide\033[0m:  Unicode decode
#/                    \033[32mhtml\033[0m:   HTML encode
#/                    \033[32mhtmlde\033[0m: HTML decode
#/                    support multiple encoders: encoder1 encoder2...
#/   -h | --help      display this help message

set -e
set -u

usage() {
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" >&2 && exit 1
}

set_command() {
    _BASE32=$(command -v base32) || command_not_found "base32"
    _BASE64=$(command -v base64) || command_not_found "base64"
    _XXD=$(command -v xxd) || command_not_found "xxd"
}

set_var() {
    _INPUT_LEN="${#@}"
    _INPUT_STR="$(echo -n "${*: -1}")"
    _ENCODE_LIST=("${@:1:$_INPUT_LEN-1}")
}

check_var() {
    expr "$*" : ".*--help" > /dev/null && usage
    if [[ "${#@}" -lt 2 ]]; then
        print_warn "Require at least 2 args: One is <encoder>, another one is input <string>.\n"
        usage
    fi
}

print_info() {
    # $1: info message
    printf "%b\n" "\033[32m[INFO]\033[0m $1" >&2
}

print_warn() {
    # $1: warning message
    printf "%b\n" "\033[33m[WARNING]\033[0m $1" >&2
}

print_error() {
    # $1: error message
    printf "%b\n" "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

command_not_found() {
    # $1: command name
    print_error "$1 command not found!"
}

f_b32() {
    # $1: input string
    echo -n "$1" | ${_BASE32} -w 0
}

f_b32de() {
    # $1: input string
    echo -n "$1" | $_BASE32 -d
}

f_b64() {
    # $1: input string
    echo -n "$1" | ${_BASE64} -w 0
}

f_b64de() {
    # $1: input string
    echo -n "$1" | $_BASE64 -d
}

f_hex() {
    # $1: input string
    echo -n "$1" | $_XXD -p | sed -E ':a;N;s/\n//;ba'
}

f_xhex() {
    # $1: input string
    echo -n "$1" | $_XXD -p | fold -2 | awk '{printf "\\x%s", $1}'
}

f_hexde() {
    # $1: input string
    echo -n "$1" | sed -E 's/\\x//g' | $_XXD -r -p
}

f_url() {
    # $1: input string
    # code from https://stackoverflow.com/a/10660730
    local string="${1}"
    local strlen=${#string}
    local encoded pos c o

    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )  printf -v o '%%%02X' "'$c"
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

f_urlde() {
    # $1: input string
    printf '%b' "${1//%/\\x}"
}

f_uni() {
    # $1: input string
    # code from https://stackoverflow.com/a/51309827
    local o=""
    IFS=''
    while read -r -n 1 u; do
        [[ -n "$u" ]] && o+=$(printf '\\u%04x' "'$u")
    done <<< "$1"
    echo "$o"
}

f_unide() {
    # $1: input string
    echo -e "$1"
}

f_html() {
    # $1: input string
    sed -E s:\&:\\\&amp\;:g <<< "$1" \
        | sed -E s:\":\\\&quot\;:g  \
        | sed -E s:\':\\\&apos\;:g \
        | sed -E s:\<:\\\&lt\;:g \
        | sed -E s:\>:\\\&gt\;:g \
        | sed -E s:\ :\\\&nbsp\;:g \
        | sed -E s:¡:\\\&iexcl\;:g \
        | sed -E s:¢:\\\&cent\;:g \
        | sed -E s:£:\\\&pound\;:g \
        | sed -E s:¤:\\\&curren\;:g \
        | sed -E s:¥:\\\&yen\;:g \
        | sed -E s:¦:\\\&brvbar\;:g \
        | sed -E s:§:\\\&sect\;:g \
        | sed -E s:¨:\\\&uml\;:g \
        | sed -E s:©:\\\&copy\;:g \
        | sed -E s:ª:\\\&ordf\;:g \
        | sed -E s:«:\\\&laquo\;:g \
        | sed -E s:¬:\\\&not\;:g \
        | sed -E s:­:\\\&shy\;:g \
        | sed -E s:®:\\\&reg\;:g \
        | sed -E s:¯:\\\&macr\;:g \
        | sed -E s:°:\\\&deg\;:g \
        | sed -E s:±:\\\&plusmn\;:g \
        | sed -E s:²:\\\&sup2\;:g \
        | sed -E s:³:\\\&sup3\;:g \
        | sed -E s:´:\\\&acute\;:g \
        | sed -E s:µ:\\\&micro\;:g \
        | sed -E s:¶:\\\&para\;:g \
        | sed -E s:·:\\\&middot\;:g \
        | sed -E s:¸:\\\&cedil\;:g \
        | sed -E s:¹:\\\&sup1\;:g \
        | sed -E s:º:\\\&ordm\;:g \
        | sed -E s:»:\\\&raquo\;:g \
        | sed -E s:¼:\\\&frac14\;:g \
        | sed -E s:½:\\\&frac12\;:g \
        | sed -E s:¾:\\\&frac34\;:g \
        | sed -E s:¿:\\\&iquest\;:g \
        | sed -E s:×:\\\&times\;:g \
        | sed -E s:÷:\\\&divide\;:g \
        | sed -E s:À:\\\&Agrave\;:g \
        | sed -E s:Á:\\\&Aacute\;:g \
        | sed -E s:Â:\\\&Acirc\;:g \
        | sed -E s:Ã:\\\&Atilde\;:g \
        | sed -E s:Ä:\\\&Auml\;:g \
        | sed -E s:Å:\\\&Aring\;:g \
        | sed -E s:Æ:\\\&AElig\;:g \
        | sed -E s:Ç:\\\&Ccedil\;:g \
        | sed -E s:È:\\\&Egrave\;:g \
        | sed -E s:É:\\\&Eacute\;:g \
        | sed -E s:Ê:\\\&Ecirc\;:g \
        | sed -E s:Ë:\\\&Euml\;:g \
        | sed -E s:Ì:\\\&Igrave\;:g \
        | sed -E s:Í:\\\&Iacute\;:g \
        | sed -E s:Î:\\\&Icirc\;:g \
        | sed -E s:Ï:\\\&Iuml\;:g \
        | sed -E s:Ð:\\\&ETH\;:g \
        | sed -E s:Ñ:\\\&Ntilde\;:g \
        | sed -E s:Ò:\\\&Ograve\;:g \
        | sed -E s:Ó:\\\&Oacute\;:g \
        | sed -E s:Ô:\\\&Ocirc\;:g \
        | sed -E s:Õ:\\\&Otilde\;:g \
        | sed -E s:Ö:\\\&Ouml\;:g \
        | sed -E s:Ø:\\\&Oslash\;:g \
        | sed -E s:Ù:\\\&Ugrave\;:g \
        | sed -E s:Ú:\\\&Uacute\;:g \
        | sed -E s:Û:\\\&Ucirc\;:g \
        | sed -E s:Ü:\\\&Uuml\;:g \
        | sed -E s:Ý:\\\&Yacute\;:g \
        | sed -E s:Þ:\\\&THORN\;:g \
        | sed -E s:ß:\\\&szlig\;:g \
        | sed -E s:à:\\\&agrave\;:g \
        | sed -E s:á:\\\&aacute\;:g \
        | sed -E s:â:\\\&acirc\;:g \
        | sed -E s:ã:\\\&atilde\;:g \
        | sed -E s:ä:\\\&auml\;:g \
        | sed -E s:å:\\\&aring\;:g \
        | sed -E s:æ:\\\&aelig\;:g \
        | sed -E s:ç:\\\&ccedil\;:g \
        | sed -E s:è:\\\&egrave\;:g \
        | sed -E s:é:\\\&eacute\;:g \
        | sed -E s:ê:\\\&ecirc\;:g \
        | sed -E s:ë:\\\&euml\;:g \
        | sed -E s:ì:\\\&igrave\;:g \
        | sed -E s:í:\\\&iacute\;:g \
        | sed -E s:î:\\\&icirc\;:g \
        | sed -E s:ï:\\\&iuml\;:g \
        | sed -E s:ð:\\\&eth\;:g \
        | sed -E s:ñ:\\\&ntilde\;:g \
        | sed -E s:ò:\\\&ograve\;:g \
        | sed -E s:ó:\\\&oacute\;:g \
        | sed -E s:ô:\\\&ocirc\;:g \
        | sed -E s:õ:\\\&otilde\;:g \
        | sed -E s:ö:\\\&ouml\;:g \
        | sed -E s:ø:\\\&oslash\;:g \
        | sed -E s:ù:\\\&ugrave\;:g \
        | sed -E s:ú:\\\&uacute\;:g \
        | sed -E s:û:\\\&ucirc\;:g \
        | sed -E s:ü:\\\&uuml\;:g \
        | sed -E s:ý:\\\&yacute\;:g \
        | sed -E s:þ:\\\&thorn\;:g \
        | sed -E s:ÿ:\\\&yuml\;:g
}

f_htmlde() {
    # $1: input string
    sed -E s:\&quot\;:\":g <<< "$1" \
        | sed -E s:\&apos\;:\':g \
        | sed -E s:\&lt\;:\<:g \
        | sed -E s:\&gt\;:\>:g \
        | sed -E s:\&nbsp\;:\ :g \
        | sed -E s:\&iexcl\;:¡:g \
        | sed -E s:\&cent\;:¢:g \
        | sed -E s:\&pound\;:£:g \
        | sed -E s:\&curren\;:¤:g \
        | sed -E s:\&yen\;:¥:g \
        | sed -E s:\&brvbar\;:¦:g \
        | sed -E s:\&sect\;:§:g \
        | sed -E s:\&uml\;:¨:g \
        | sed -E s:\&copy\;:©:g \
        | sed -E s:\&ordf\;:ª:g \
        | sed -E s:\&laquo\;:«:g \
        | sed -E s:\&not\;:¬:g \
        | sed -E s:\&shy\;:­:g \
        | sed -E s:\&reg\;:®:g \
        | sed -E s:\&macr\;:¯:g \
        | sed -E s:\&deg\;:°:g \
        | sed -E s:\&plusmn\;:±:g \
        | sed -E s:\&sup2\;:²:g \
        | sed -E s:\&sup3\;:³:g \
        | sed -E s:\&acute\;:´:g \
        | sed -E s:\&micro\;:µ:g \
        | sed -E s:\&para\;:¶:g \
        | sed -E s:\&middot\;:·:g \
        | sed -E s:\&cedil\;:¸:g \
        | sed -E s:\&sup1\;:¹:g \
        | sed -E s:\&ordm\;:º:g \
        | sed -E s:\&raquo\;:»:g \
        | sed -E s:\&frac14\;:¼:g \
        | sed -E s:\&frac12\;:½:g \
        | sed -E s:\&frac34\;:¾:g \
        | sed -E s:\&iquest\;:¿:g \
        | sed -E s:\&times\;:×:g \
        | sed -E s:\&divide\;:÷:g \
        | sed -E s:\&Agrave\;:À:g \
        | sed -E s:\&Aacute\;:Á:g \
        | sed -E s:\&Acirc\;:Â:g \
        | sed -E s:\&Atilde\;:Ã:g \
        | sed -E s:\&Auml\;:Ä:g \
        | sed -E s:\&Aring\;:Å:g \
        | sed -E s:\&AElig\;:Æ:g \
        | sed -E s:\&Ccedil\;:Ç:g \
        | sed -E s:\&Egrave\;:È:g \
        | sed -E s:\&Eacute\;:É:g \
        | sed -E s:\&Ecirc\;:Ê:g \
        | sed -E s:\&Euml\;:Ë:g \
        | sed -E s:\&Igrave\;:Ì:g \
        | sed -E s:\&Iacute\;:Í:g \
        | sed -E s:\&Icirc\;:Î:g \
        | sed -E s:\&Iuml\;:Ï:g \
        | sed -E s:\&ETH\;:Ð:g \
        | sed -E s:\&Ntilde\;:Ñ:g \
        | sed -E s:\&Ograve\;:Ò:g \
        | sed -E s:\&Oacute\;:Ó:g \
        | sed -E s:\&Ocirc\;:Ô:g \
        | sed -E s:\&Otilde\;:Õ:g \
        | sed -E s:\&Ouml\;:Ö:g \
        | sed -E s:\&Oslash\;:Ø:g \
        | sed -E s:\&Ugrave\;:Ù:g \
        | sed -E s:\&Uacute\;:Ú:g \
        | sed -E s:\&Ucirc\;:Û:g \
        | sed -E s:\&Uuml\;:Ü:g \
        | sed -E s:\&Yacute\;:Ý:g \
        | sed -E s:\&THORN\;:Þ:g \
        | sed -E s:\&szlig\;:ß:g \
        | sed -E s:\&agrave\;:à:g \
        | sed -E s:\&aacute\;:á:g \
        | sed -E s:\&acirc\;:â:g \
        | sed -E s:\&atilde\;:ã:g \
        | sed -E s:\&auml\;:ä:g \
        | sed -E s:\&aring\;:å:g \
        | sed -E s:\&aelig\;:æ:g \
        | sed -E s:\&ccedil\;:ç:g \
        | sed -E s:\&egrave\;:è:g \
        | sed -E s:\&eacute\;:é:g \
        | sed -E s:\&ecirc\;:ê:g \
        | sed -E s:\&euml\;:ë:g \
        | sed -E s:\&igrave\;:ì:g \
        | sed -E s:\&iacute\;:í:g \
        | sed -E s:\&icirc\;:î:g \
        | sed -E s:\&iuml\;:ï:g \
        | sed -E s:\&eth\;:ð:g \
        | sed -E s:\&ntilde\;:ñ:g \
        | sed -E s:\&ograve\;:ò:g \
        | sed -E s:\&oacute\;:ó:g \
        | sed -E s:\&ocirc\;:ô:g \
        | sed -E s:\&otilde\;:õ:g \
        | sed -E s:\&ouml\;:ö:g \
        | sed -E s:\&oslash\;:ø:g \
        | sed -E s:\&ugrave\;:ù:g \
        | sed -E s:\&uacute\;:ú:g \
        | sed -E s:\&ucirc\;:û:g \
        | sed -E s:\&uuml\;:ü:g \
        | sed -E s:\&yacute\;:ý:g \
        | sed -E s:\&thorn\;:þ:g \
        | sed -E s:\&yuml\;:ÿ:g \
        | sed -E s:\&amp\;:\\\&:g
}

main() {
    check_var "$@"
    set_var "$@"
    set_command

    local list=(b32 b32de b64 b64de hex xhex hexde url urlde uni unide html htmlde)
    local str="$_INPUT_STR"

    for i in "${_ENCODE_LIST[@]}"; do
        if [[ " ${list[*]} " == *" $i "* ]]; then
            str=$(eval "f_${i}" '"$str"')
        else
            print_error "Encoder $i is not supported!"
        fi
    done

    echo "$str"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
