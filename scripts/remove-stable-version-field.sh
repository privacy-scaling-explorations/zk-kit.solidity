#!/bin/sh

# shellcheck source=lib.sh
. ./scripts/lib.sh

remove_stable_version() {
    pkg_yaml_file="$1"

    if [ ! -f "$pkg_yaml_file" ]; then
        red "Error: $pkg_yaml_file not found" >&2
        return 1
    fi

    yaml_content=$(cat "$pkg_yaml_file")
    updated_yaml=$(echo "$yaml_content" | sed '/stableVersion/d')
    echo "$updated_yaml" > "$pkg_yaml_file"
}

main() {
    [ "$#" -ne 1 ] && usage "package"
    pkg_name="$1"
    remove_stable_version "packages/$pkg_name/package.yaml"
    pnpm format:write
}

main "$@"
