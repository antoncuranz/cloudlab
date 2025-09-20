#!/bin/bash
cat initial-secrets.yaml | op inject | kubectl apply --server-side --field-manager flux-client-side-apply -f -