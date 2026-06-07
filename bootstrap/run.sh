#!/bin/bash
set -euo pipefail

environment="${1:-production}"

case "$environment" in
  production)
    flux_path=./clusters/production
    ;;
  local)
    flux_path=./clusters/local
    ;;
  *)
    echo "usage: $0 [production|local]" >&2
    exit 1
    ;;
esac

cat initial-secrets.yaml | op inject | kubectl apply --server-side --field-manager flux-client-side-apply -f -

"$(dirname "$0")/install-cilium.sh"

echo "Bootstrapping ${environment} from ${flux_path}. Use production and local against separate target clusters; both reuse the standard flux-system names."

flux bootstrap github \
  --owner=antoncuranz \
  --repository=cloudlab \
  --branch=main \
  --path="${flux_path}" \
  --personal
