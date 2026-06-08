# cloudlab

## Layout

```text
apps/
  baikal/
  kompass/
infrastructure/
  database/
  monitoring/
  networking/
  secrets/
  storage/
clusters/
  local/
  prod/
```

- `clusters/local` and `clusters/prod` are the Flux sync entrypoints.
- `clusters/local/apps` and `clusters/prod/apps` aggregate app-owned Flux `Kustomization` manifests.
- `clusters/local/infrastructure` and `clusters/prod/infrastructure` aggregate infrastructure-owned Flux `Kustomization` manifests.
- Deployable units own their Flux entrypoints directly in `apps/*` and `infrastructure/**`.
- Shared/default entrypoints use `app.yaml`.
- Environment-specific entrypoints use `local.yaml` and `prod.yaml` only when behavior diverges.

## Environment rules

- Cluster aggregators compose component-owned manifests only.
- Cluster aggregators may apply uniform defaults, but they do not rewrite component `spec.path` values.
- Local external-secrets uses the fake provider-backed `ClusterSecretStore` from `infrastructure/secrets/external-secrets/env-local`.
- Production external-secrets uses the 1Password-backed `ClusterSecretStore` from `infrastructure/secrets/external-secrets/env-prod`.
- Production app volsync behavior lives in app-owned `prod.yaml` manifests.

## Bootstrap

```bash
./bootstrap/run.sh prod
./bootstrap/run.sh local
```

The script selects:

- branch `main` with `./clusters/prod`
- branch `local` with `./clusters/local`

## Verification

```bash
kustomize build clusters/local/apps
kustomize build clusters/local/infrastructure
kustomize build clusters/prod/apps
kustomize build clusters/prod/infrastructure
kustomize build clusters/local
kustomize build clusters/prod
```

```bash
kustomize build clusters/local | rg 'name: infrastructure|name: apps|dependsOn:'
kustomize build clusters/prod | rg 'name: infrastructure|name: apps|dependsOn:'
```

```bash
kustomize build infrastructure/secrets/external-secrets/env-local | rg 'fake:'
kustomize build infrastructure/secrets/external-secrets/env-prod | rg 'onepassword:'
```
