#!/usr/bin/env sh

set -eu

publish_npm() {
  yarn workspaces foreach -A --no-private npm publish --tolerate-republish --access public
}

clean() {
  pkg="$1"
  exclude_regex="\.\|\./\.git\|\./packages\|\./\|\./packages/$pkg\|\./LICENSE"
  find . -maxdepth 2 -not -regex "$exclude_regex" -exec rm -rf {} +
}

publish_forge_pkg() {
  pkg="$1"
  version=$(jq -r '.version' "packages/$pkg/package.json")

  git checkout -b "$pkg"

  clean "$pkg"
  mv "packages/$pkg"/src .
  mv "packages/$pkg"/README.md .
  rm -fr "packages/$pkg"
  git commit -am "$version"
  git push origin "$pkg"

  git checkout main

}

publish_forge_pkgs() {
  # http://mywiki.wooledge.org/BashFAQ/001
  # https://github.com/koalaman/shellcheck/wiki/SC2012
  find packages -maxdepth 1 -mindepth 1 -printf '%P\n' | while read -r pkg; do
    publish_forge_pkg "$pkg"
  done
}

main() {
  publish_forge_pkgs
  # TODO: uncomment
  # publish_npm
}

main
