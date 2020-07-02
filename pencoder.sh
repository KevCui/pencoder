#!/usr/bin/env bash
#
# Powerful payload encoder powered by Bash
#
#/ Usage:
#/   ./pencoder.sh [encoder1] [encoder2] ... <string>
#/
#/ Options:
#/   string           input string
#/   encoder          \033[32mb32en\033[0m: base32 encode
#/                    \033[32mb32de\033[0m: base32 decode
#/                    \033[32mb64en\033[0m: base64 encode
#/                    \033[32mb64de\033[0m: base64 decode
#/                    \033[32mhexen\033[0m: hex encode
#/                    \033[32mhexde\033[0m: hex decode
#/                    \033[32murlen\033[0m: URL encode
#/                    \033[32murlde\033[0m: URL decode
#/                    \033[32municodeen\033[0m: Unicode \\u-escaped numbers encode
#/                    \033[32municodede\033[0m: Unicode \\u-escaped numbers decode
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

f_b32en() {
    # $1: input string
    echo -n "$1" | ${_BASE32}
}

f_b32de() {
    # $1: input string
    echo -n "$1" | $_BASE32 -d
}

f_b64en() {
    # $1: input string
    echo -n "$1" | ${_BASE64}
}

f_b64de() {
    # $1: input string
    echo -n "$1" | $_BASE64 -d
}

f_hexen() {
    # $1: input string
    echo -n "$1" | $_XXD -p | sed -E ':a;N;s/\n//;ba'
}

f_hexde() {
    # $1: input string
    echo -n "$1" | $_XXD -r -p
}

f_urlen() {
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

f_unicodeen() {
    # $1: input string
    # code from https://stackoverflow.com/a/51309827
    local o=""
    IFS=''
    while read -r -n 1 u; do
        [[ -n "$u" ]] && o+=$(printf '\\u%04x' "'$u")
    done <<< "$1"
    echo "$o"
}

f_unicodede() {
    # $1: input string
    echo -e "$1"
}

main() {
    check_var "$@"
    set_var "$@"
    set_command

    local list=(b32en b32de b64en b64de hexen hexde urlen urlde unicodeen unicodede)
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
