#!/usr/bin/env bash
set -euo pipefail
mkdir -p paper/plugins velocity/plugins
jq -r '.paper[] | "\(.name) \(.url)"' manifest.json \
  | while read name url; do
      curl -fSL "$url" -o "paper/plugins/${name}.jar"
    done
jq -r '.velocity[] | "\(.name) \(.url)"' manifest.json \
  | while read name url; do
      curl -fSL "$url" -o "velocity/plugins/${name}.jar"
    done
