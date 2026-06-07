# cloudlab

## Layout

```text
apps/
  base/
  production/
  local/
infrastructure/
  base/
  production/
  local/
clusters/
  base/
  production/
  local/
```

- `apps/base`, `infrastructure/base`, and `clusters/base` hold the shared Flux-managed resources.
- `apps/production` and `infrastructure/production` are thin production overlays.
- `apps/local` and `infrastructure/local` apply local-only safety patches.
- `clusters/production` and `clusters/local` are alternative Flux sync entrypoints for separate target clusters.

## Bootstrap

Use different target clusters for production and local. Both entrypoints intentionally reuse the standard `flux-system` object names.

```bash
./bootstrap/run.sh production
./bootstrap/run.sh local
```

The script selects:

- `./clusters/production` for production
- `./clusters/local` for local

## Local safety behavior

`infrastructure/local` keeps the same main controllers as production, but changes the risky parts:

- cert-manager keeps the `letsencrypt-prod` name but switches to `selfSigned: {}`
- external-dns still uses the Cloudflare provider, but is constrained to `domainFilters: [local.test]`
- external-dns uses `txtOwnerId: cloudlab-local`
- a placeholder `cloudflare-api-token` secret is included for cleaner local controller startup
- app-level volsync components are removed from local app Flux `Kustomization` resources

## Limitations

- Local certificates are self-signed.
- Local external-dns is intentionally filtered away from the production hostnames already present in app manifests.
- Local app overlays disable app-level volsync restore and backup resources; the volsync controller may still exist in infrastructure.

## Verification

Production:

```bash
kustomize build apps/production
kustomize build infrastructure/production
kustomize build clusters/production
```

Local:

```bash
kustomize build infrastructure/local
kustomize build infrastructure/local | rg 'name: cert-manager|name: external-dns|selfSigned|domainFilters|txtOwnerId'
kustomize build apps/local
kustomize build apps/local | rg 'components:'
kustomize build apps/local | rg 'volsync.backube'
kustomize build clusters/local
```

Expected local results:

- the local cert-manager Flux `Kustomization` includes a patch that removes ACME and adds `selfSigned: {}` for `ClusterIssuer/letsencrypt-prod`
- the local external-dns Flux `Kustomization` includes patches for `domainFilters: [local.test]` and `txtOwnerId: cloudlab-local`
- `kustomize build apps/local | rg 'components:'` returns no matches
- `kustomize build apps/local | rg 'volsync.backube'` returns no matches
