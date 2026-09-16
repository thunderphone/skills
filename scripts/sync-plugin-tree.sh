#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/plugins/thunderphone/skills"
MODE="${1:-sync}"

skills=()
while IFS= read -r skill; do
  skills+=("$skill")
done < <(find "$ROOT" -mindepth 2 -maxdepth 2 -name SKILL.md -not -path '*/plugins/*' -print | sed 's#/SKILL.md$##' | sort)

if [[ "$MODE" == "--check" ]]; then
  status=0
  for source in "${skills[@]}"; do
    name="$(basename "$source")"
    if [[ ! -d "$DEST/$name" ]]; then
      echo "missing plugin skill: $name" >&2
      status=1
    elif ! diff -qr "$source" "$DEST/$name"; then
      status=1
    fi
  done
  for mirrored in "$DEST"/*; do
    [[ -e "$mirrored" ]] || continue
    name="$(basename "$mirrored")"
    [[ -d "$ROOT/$name" ]] || { echo "extra plugin skill: $name" >&2; status=1; }
  done
  exit "$status"
fi

if [[ "$MODE" != "sync" ]]; then
  echo "usage: $0 [sync|--check]" >&2
  exit 2
fi

mkdir -p "$DEST"
for mirrored in "$DEST"/*; do
  [[ -e "$mirrored" ]] || continue
  name="$(basename "$mirrored")"
  [[ -d "$ROOT/$name" ]] || rm -rf "$mirrored"
done
for source in "${skills[@]}"; do
  name="$(basename "$source")"
  rm -rf "$DEST/$name"
  cp -R "$source" "$DEST/$name"
done
