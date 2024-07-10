#!/bin/sh

set -eu

remove_stable_version() {
  package_json_path="$1"
  sed -i '/^[[:space:]]*"stableVersion":/d' "$package_json_path"
}

main() {
  package_json_path="packages/$1/package.json"
  remove_stable_version "$package_json_path"
}

main "$@"
