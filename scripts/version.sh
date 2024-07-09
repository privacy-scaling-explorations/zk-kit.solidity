#!/usr/bin/env sh

# shellcheck source=lib.sh
. ./scripts/lib.sh

main() {
    [ "$#" -ne 2 ] && usage "package" "version"

    if [ ! -d "packages/$1" ]; then
        red "Error: Package $1 does not exist"
        exit 1
    fi

    pkg="$1"
    version="$2"

    sed -i "s/version: .*/version: $version/" "packages/$pkg/contracts/package.yaml"
    pnpm remove:stable-version-field "$pkg"
    NO_HOOK=1 git commit -am "chore($pkg): v$version"
    git tag "$pkg.sol-v$version"
}

main "$@"
