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
  base/
  local/
  prod/
```

- `clusters/base/apps` holds shared app Flux `Kustomization` objects.
- `clusters/base/infrastructure` holds the shared infrastructure Flux graph.
- `clusters/local` and `clusters/prod` are the Flux sync entrypoints.
- `clusters/local/apps` and `clusters/prod/apps` render env-specific app Flux objects.
- `clusters/local/infrastructure` and `clusters/prod/infrastructure` render env-specific infrastructure Flux objects.
- Component directories live directly under `apps/` and `infrastructure/`.
- Only components with local differences keep `base/` and `local/`.
- Production app-only volsync behavior is injected from `clusters/prod/apps/patches.yaml`.

## Environment rules

- Shared nested Flux paths live in `clusters/base`.
- `clusters/local/infrastructure/patches.yaml` rewrites only the infrastructure Flux `spec.path` values that differ locally.
- `clusters/prod/apps/patches.yaml` is the only app-specific override layer.
- Base external-secrets uses the real provider-backed `ClusterSecretStore`.
- Local external-secrets overrides it with a fake provider.
- Production app overrides add volsync.
- Base apps do not render app-level volsync resources.

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
kustomize build clusters/base
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
kustomize build infrastructure/networking/cert-manager/local | rg 'selfSigned|acme'
kustomize build infrastructure/secrets/external-secrets/local | rg 'fake:'
kustomize build infrastructure/secrets/external-secrets/base | rg 'onepassword:'
```
