#!/usr/bin/env sh

set -eu

publish_npm() {
  yarn workspaces foreach -A --no-private npm publish --tolerate-republish --access public
}

clean_root() {
    pkg="$1"
    exclude_regex="\./\.git\|\./packages\|\./\|\./packages/$pkg\|\./LICENSE"
    find . -maxdepth 1 -not -regex "$exclude_regex" -exec rm -rf {} +
}

publish_forge_pkg() {
    pkg="$1"
    version=$(jq -r '.version' "packages/$pkg/package.json")

    clean_root "$pkg"
    mv "packages/$pkg/{src,README.md}" .
    rm -fr "packages/$pkg"

    git checkout -b "$package"
    git commit -am "$version"
    git push origin "$package"
}

main() {
 pkg="$1"
 clean_root "$pkg"
 publish_forge
 publish_npm
}

main "$@"
