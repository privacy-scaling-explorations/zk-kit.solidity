#!/usr/bin/env sh

set -eu

clean() {
  # TODO: use regex instead
  find . -maxdepth 1 \
    ! -path . \
    ! -path ./.git \
    ! -path "./.git/*" \
    ! -path ./packages \
    ! -path ./LICENSE \
    -exec rm -rf {} +
}

main() {
  git fetch origin main
  latest_main_commit_msg=$(git log origin/main -1 --pretty=%B)

  git checkout -b forge
  git fetch origin forge
  git pull origin forge --rebase || true

  clean

  # http://mywiki.wooledge.org/BashFAQ/001
  # https://github.com/koalaman/shellcheck/wiki/SC2012
  find packages -maxdepth 1 -mindepth 1 -printf '%P\n' | while read -r pkg; do
    mkdir "$pkg"
    mv "packages/$pkg/src" "$pkg"
    mv "packages/$pkg/README.md" "$pkg"
    git add "$pkg"
  done

  rm -fr "packages"

  git commit -am "$latest_main_commit_msg"
  git push origin forge
}

main
