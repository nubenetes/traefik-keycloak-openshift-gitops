# Security Policy

> ⚠️ This project is **AI-generated and has not been tested on a live cluster**.
> It is a reference/template, not a production-hardened product. Review every
> manifest and validate in a non-production environment before real use.

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Use GitHub's private reporting: **Security → Report a vulnerability**
([advisories page](https://github.com/nubenetes/traefik-keycloak-openshift-gitops/security/advisories/new)).
We'll acknowledge the report and work with you on a fix and coordinated
disclosure.

## Scope

This repository ships Kubernetes/OpenShift manifests, Helm values and ArgoCD
definitions — not a running service. Relevant security concerns include:

- Manifest defaults that weaken the intended posture (e.g. auth bypass in the
  IngressRoute/middleware wiring, over-broad RBAC or AppProject scope).
- Guidance that could lead users to expose secrets.
- Dependency versions pinned here with known CVEs (Traefik chart, oauth2-proxy).

## Secrets handling (important)

- **Never commit real secrets.** `secrets/*.yaml` (except `*.example.yaml`),
  `tls.crt` and `tls.key` are git-ignored. The `*.example.yaml` files contain
  **dummy** values only.
- The default flow keeps `oauth2-proxy-secret` and `traefik-dashboard-tls`
  **out of git** (applied out-of-band).
- The recommended path keeps **no secret material in git**: **HashiCorp Vault +
  External Secrets Operator** (`manifests/vault/`, see
  `docs/vault-external-secrets.md`). Never commit plain `Secret` manifests.
- If you believe a secret was ever committed, rotate it immediately (Keycloak
  client secret, cookie secret, TLS key) and scrub history.

## Hardening pointers

- Keep Traefik **≥ v3.4** (required for the `statusRewrites` behavior).
- Restrict the ArgoCD `AppProject` (already scoped in `argocd/project.yaml`).
- Consider NetworkPolicies and tighter `resources` limits for production.
