# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> ⚠️ This project is **AI-generated and has not been tested on a live
> OpenShift/ArgoCD cluster**. Validation so far is limited to `kustomize build`
> and offline YAML/schema checks.

## [Unreleased]

## [0.1.3] - 2026-07-17

### Changed
- README: the architecture diagram legend is now a table (one group per row)
  instead of a single run-on paragraph, which rendered as an unreadable wall of
  text. Each group also lists the diagram nodes it covers.

### Fixed
- README: the legend used 🟦 for both "ingress/proxy" and "GitOps", so the two
  groups were indistinguishable. GitOps now uses 🔁, matching the emoji already
  on its subgraph in the diagram.

## [0.1.2] - 2026-07-16

### Added
- `renovate.json` — Renovate tracks the Traefik Helm chart version (ArgoCD
  Application + `install.sh`) and the oauth2-proxy image tag. GitHub Actions stay
  with Dependabot (Renovate's actions manager disabled to avoid duplicate PRs).
- README: "Dependency updates" section with Renovate one-time setup steps, and a
  Renovate badge.

## [0.1.1] - 2026-07-16

### Added
- CI workflow (`.github/workflows/ci.yml`): yamllint + kustomize build +
  kubeconform + shellcheck, on every push and pull request.
- Repo hygiene: `.gitattributes` (LF normalization), `.editorconfig`,
  `.github/CODEOWNERS`, `.github/FUNDING.yml`, `.github/dependabot.yml`
  (GitHub Actions updates).

## [0.1.0] - 2026-07-16

Initial reference release.

### Added
- **Traefik on OpenShift 4.20+** via the official Helm chart (pinned `41.0.2` =
  Traefik `v3.7.6`), exposed through **MetalLB** (LoadBalancer).
- **Keycloak-protected dashboard**: oauth2-proxy + ForwardAuth with the `errors`
  middleware (401→302), restricted to the `traefik-admin` role.
- **GitOps with ArgoCD** — App-of-Apps: dedicated `AppProject`, Traefik via Helm
  (multi-source with values from git), dashboard via Kustomize. Sync-waves order
  CRDs before CRs; `managedNamespaceMetadata` sets the PSA label; `ServerSideApply`
  for the large CRDs.
- **Secrets from HashiCorp Vault** via the External Secrets Operator (Kubernetes
  auth) — no secret material in git (`manifests/vault/`,
  `docs/vault-external-secrets.md`).
- **On-prem, air-gapped/disconnected** support: `ImageDigestMirrorSet` example,
  internal mirrors for chart/images/Operators, internal Git, internal-CA TLS
  (no ACME) — README §10 and `docs/air-gapped.md`.
- **Imperative fallback** (`install.sh`) for clusters without ArgoCD.
- Documentation with collapsible, color-coded Mermaid architecture diagrams
  (near-square layout).
- Community health files: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`,
  issue/PR templates, `.yamllint.yml`.
- MIT license; exhaustive README badges; repository topics and About description.

### Notes
- Not yet validated on a live cluster (see the disclaimer above).

[Unreleased]: https://github.com/nubenetes/traefik-keycloak-openshift-gitops/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/nubenetes/traefik-keycloak-openshift-gitops/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/nubenetes/traefik-keycloak-openshift-gitops/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/nubenetes/traefik-keycloak-openshift-gitops/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/nubenetes/traefik-keycloak-openshift-gitops/releases/tag/v0.1.0
