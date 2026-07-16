# Contributing

Thanks for your interest in improving this project! It is a GitOps reference for
running Traefik with a Keycloak-protected dashboard on OpenShift.

> ⚠️ **Heads-up:** this repository was **AI-generated and has not been tested on
> a live OpenShift/ArgoCD cluster**. The most valuable contributions right now
> are real-world validation, bug reports with reproduction steps, and hardening.

## Ways to contribute

- **Validate on a real cluster** and report what worked / broke (open an issue).
- **Fix bugs** in the manifests, chart values, or ArgoCD wiring.
- **Improve docs** (clarity, missing steps, diagrams).
- **Harden** the setup (Vault/External Secrets wiring, AppProject scoping,
  NetworkPolicies, resource tuning).

## Local checks before opening a PR

You don't need a cluster to validate structure. Install
[`kustomize`](https://kubectl.docs.kubernetes.io/installation/kustomize/),
[`kubeconform`](https://github.com/yannh/kubeconform) and `yamllint`, then:

```bash
# 1) Render the Kustomize base
kustomize build manifests/

# 2) Lint YAML (config in .yamllint.yml)
yamllint .

# 3) Schema-validate the rendered manifests (CRDs are skipped)
kustomize build manifests/ | kubeconform -ignore-missing-schemas -summary

# 4) Validate the ArgoCD manifests
kubeconform -ignore-missing-schemas -summary argocd/project.yaml argocd/root-app.yaml argocd/apps/*.yaml

# 5) Lint the imperative script
shellcheck install.sh
```

The same steps run in CI (`.github/workflows/ci.yml`) on every push and PR.

If you touch the Helm values, also render the chart:

```bash
helm repo add traefik https://traefik.github.io/charts && helm repo update
helm template traefik traefik/traefik --version 41.0.2 -f helm/values-traefik.yaml >/dev/null
```

## Ground rules

- **Never commit real secrets, certificates or keys.** `secrets/*.yaml` (except
  `*.example.yaml`), `tls.crt` and `tls.key` are git-ignored — keep it that way.
- **Keep the dummy values** (`traefik.apps.example.com`, `keycloak.apps.example.com`,
  `myrealm`, placeholder secrets). They must stay generic so the repo boots as a
  template; don't replace them with real infrastructure values.
- **Pin versions.** The Traefik chart is pinned (`41.0.2`) for GitOps determinism;
  if you bump it, update both `argocd/apps/traefik.yaml` and `install.sh`, and
  keep Traefik **≥ v3.4**.
- **Update the docs** when you change behavior or layout (README and, if relevant,
  `argocd/README.md`).

## Commit & PR conventions

- Write clear, imperative commit subjects (e.g. `fix: correct middleware order`).
  [Conventional Commits](https://www.conventionalcommits.org/) prefixes
  (`feat:`, `fix:`, `docs:`, `ci:`, `refactor:`, `chore:`) are appreciated.
- One logical change per PR; fill in the PR template.
- Link the issue your PR addresses (`Closes #NN`).

## Code of Conduct

By participating you agree to abide by our
[Code of Conduct](CODE_OF_CONDUCT.md).
