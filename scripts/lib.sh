#!/usr/bin/env sh

set -eu

ORANGE='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

log() {
    printf "%b\n" "$1"
}

red() {
    printf "%b\n" "${RED}$1${RESET}" >&2
}

usage() {
    red "Error: Invalid number of arguments"
    log "Usage: $0 $ORANGE$*$RESET"
    exit 1
}
