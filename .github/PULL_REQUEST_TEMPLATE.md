<!-- Thanks for contributing! Keep the description tight and check the boxes that apply. -->

## Summary

<!-- What does this PR change and why? Link any related issue: Closes #123 -->

## Type of change

- [ ] 🐛 Bug fix
- [ ] ✨ Feature / enhancement
- [ ] 📝 Documentation
- [ ] 🔧 CI / tooling
- [ ] ♻️ Refactor (no functional change)

## How was this validated?

<!-- This project has no live-cluster CI. Tell us what you actually ran. -->

- [ ] `kustomize build manifests/` succeeds
- [ ] `yamllint .` is clean
- [ ] `kubeconform -ignore-missing-schemas` passes on the rendered output
- [ ] For ArgoCD changes: `argocd app diff` / applied on a test cluster
- [ ] For chart values: `helm template traefik traefik/traefik -f helm/values-traefik.yaml` renders

## Checklist

- [ ] I did **not** commit real secrets, certs or keys.
- [ ] Dummy values (`*.apps.example.com`, `myrealm`, placeholders) are preserved, not replaced with real ones.
- [ ] Docs (README / argocd/README) updated if behavior or layout changed.
- [ ] Commit messages are descriptive.

## Notes for reviewers

<!-- Anything that needs special attention, trade-offs, follow-ups. -->
