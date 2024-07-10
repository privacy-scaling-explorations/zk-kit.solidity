#!/usr/bin/env sh

set -eu

main() {
  pkg="$1"
  version="$2"

  yarn workspace @zk-kit/"$pkg".sol version "$version"
  scripts/remove-stable-version-field.ts "$pkg"
  yarn format:write
  NO_HOOK=1 git commit -am "chore($pkg): v$version"
  git tag "$pkg.sol-v$version"
}

main "$@"
