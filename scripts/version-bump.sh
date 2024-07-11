#!/usr/bin/env sh

set -eu

ORANGE='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

log() {
  printf "%b\n" "$1"
}

red() {
  log "${RED}$1${RESET}"
}

usage() {
  red "Error: Missing arguments"
  log "Usage: $0 ${ORANGE}package$RESET ${ORANGE}version$RESET"
  exit 1
}

main() {
  [ "$#" -ne 2 ] && usage

  pkg="$1"
  version="$2"

  yarn workspace @zk-kit/"$pkg".sol version "$version"
  scripts/remove-stable-version-field.sh "$pkg"
  yarn format:write
  NO_HOOK=1 git commit -am "chore($pkg): v$version"
  git tag "$pkg.sol-v$version"
}

main "$@"
