#!/usr/bin/env bash
set -euo pipefail

# cria as pastas de plugins (se ainda não existirem)
mkdir -p terraform/paper/plugins terraform/velocity/plugins

# baixa plugins do PaperMC
jq -r '.paper[] | "\(.name) \(.url)"' terraform/manifest.json \
  | while read -r name url; do
      echo "[Paper] Baixando $name…"
      curl -fSL "$url" -o "terraform/paper/plugins/${name}.jar"
    done

# baixa plugins do Velocity (se tiver algum listado)
jq -r '.velocity[] | "\(.name) \(.url)"' terraform/manifest.json \
  | while read -r name url; do
      echo "[Velocity] Baixando $name…"
      curl -fSL "$url" -o "terraform/velocity/plugins/${name}.jar"
    done

echo "✔️ Plugins baixados em terraform/{paper,velocity}/plugins"
