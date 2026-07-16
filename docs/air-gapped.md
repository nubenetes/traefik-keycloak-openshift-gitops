# Air-gapped / disconnected OpenShift (on-prem)

This solution is designed for a **disconnected OpenShift Container Platform**
cluster with **no internet egress**. Nothing is pulled from the public internet
at runtime: charts, container images and Operators all come from **internal
mirrors**. This is also why **MetalLB** provides the LoadBalancer (there is no
cloud LB on-prem).

This guide covers the four things you must mirror/redirect before installing:
**images**, the **Helm chart**, the **Operators**, and **Git**. Plus TLS without
ACME.

> Prerequisite: an internal, cluster-reachable **image registry** (e.g. Quay,
> Harbor, Nexus, Artifactory) and, for the chart, an internal **Helm/OCI** repo.
> A host with temporary internet access to *pull-then-push* the artifacts, or a
> portable mirror (`oc-mirror` to disk, then into the enclave).

---

## 1. Container images

Images used by this deployment:

| Component | Upstream image | Pinned version |
|---|---|---|
| Traefik | `docker.io/traefik` | `v3.7.6` (chart 41.0.2) |
| oauth2-proxy | `quay.io/oauth2-proxy/oauth2-proxy` | `v7.7.1` |

(ArgoCD, MetalLB and External Secrets images arrive via their Operators — see §3.)

**Mirror them** to your registry:

```bash
oc image mirror docker.io/traefik:v3.7.6 \
  registry.internal.example.com/traefik/traefik:v3.7.6
oc image mirror quay.io/oauth2-proxy/oauth2-proxy:v7.7.1 \
  registry.internal.example.com/oauth2-proxy/oauth2-proxy:v7.7.1
```

**Redirect pulls transparently** with an `ImageDigestMirrorSet` so the manifests
keep their upstream references and the cluster resolves them to the mirror:

```bash
# edit the registry host first
oc apply -f air-gapped/imagedigestmirrorset.example.yaml
```

> IDMS rolls out via the Machine Config Operator (nodes may reboot). On clusters
> older than 4.13 use `ImageContentSourcePolicy` instead.
>
> Alternatively, skip IDMS and set the images explicitly:
> - Traefik: `image.registry` / `image.repository` in `helm/values-traefik.yaml`.
> - oauth2-proxy: the `image:` field in `manifests/oauth2-proxy/deployment.yaml`.

## 2. Traefik Helm chart

ArgoCD cannot reach `https://traefik.github.io/charts` in an enclave. Mirror the
chart to an internal repo and point ArgoCD at it.

**Option A — OCI registry (recommended):**

```bash
helm pull traefik --repo https://traefik.github.io/charts --version 41.0.2   # on a connected host
helm push traefik-41.0.2.tgz oci://registry.internal.example.com/helm-charts  # into the enclave
```

Then in `argocd/apps/traefik.yaml` set the chart source:

```yaml
    - repoURL: registry.internal.example.com/helm-charts   # OCI, no https://
      chart: traefik
      targetRevision: 41.0.2
```

**Option B — HTTP Helm repo** (ChartMuseum/Nexus/Artifactory): host the chart and
set `repoURL: https://charts.internal.example.com`.

**Option C — vendored chart**: commit the unpacked chart under `helm/vendor/traefik/`
and reference it as a local path source. Fully self-contained, but you own updates.

## 3. Operators (MetalLB, External Secrets)

Install from a **disconnected OperatorHub**. Build a mirrored catalog with
`oc-mirror` and apply the generated `CatalogSource` + `ImageContentSourcePolicy`/IDMS:

```bash
# Example ImageSetConfiguration (connected side): mirror the operators you need
# (metallb-operator, external-secrets-operator or the community equivalent),
# then transfer and `oc-mirror` into the cluster.
oc mirror --config imageset-config.yaml docker://registry.internal.example.com
```

Then install the Operators from the internal catalog via OperatorHub / a
`Subscription`. See the OpenShift docs for "Using Operator Lifecycle Manager on
restricted networks".

## 4. Git (ArgoCD source)

Host this repository on your **internal Git** (Gitea, GitLab, BitBucket on-prem)
and set `repoURL` in **all** `argocd/*.yaml` accordingly. ArgoCD must be able to
reach that Git server from inside the cluster.

## 5. TLS (no ACME)

ACME / Let's Encrypt requires internet and **cannot** be used air-gapped. Use:

- An **internal CA** cert (manual): `docs/tls-secret.md` options B/C.
- **cert-manager with an internal issuer** (your enterprise CA / Vault PKI /
  a `CA` ClusterIssuer) — not the ACME issuer.

## 6. Keycloak & Vault

Both are **internal/on-prem**:

- Keycloak: the OIDC issuer URL is your internal host
  (`https://keycloak.apps.internal.example.com/realms/<realm>`). Trust its CA via
  `manifests/oauth2-proxy/trusted-ca-configmap.yaml`.
- Vault: the `SecretStore` `server:` is the in-cluster/on-prem address
  (`https://vault.vault.svc.cluster.local:8200` or an internal Route). See
  `docs/vault-external-secrets.md`.

---

## Checklist before `oc apply` / ArgoCD sync

- [ ] Images mirrored + `ImageDigestMirrorSet` applied (or explicit image refs set).
- [ ] Traefik chart mirrored + `repoURL` updated in `argocd/apps/traefik.yaml`.
- [ ] MetalLB & External Secrets Operators available in the disconnected catalog.
- [ ] `repoURL` in all `argocd/*.yaml` points to internal Git.
- [ ] TLS cert issued by an internal CA (no ACME).
- [ ] Keycloak/Vault internal addresses + CA trust configured.
- [ ] MetalLB pool matches your on-prem network (`metallb/ipaddresspool.example.yaml`).
