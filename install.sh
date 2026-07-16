#!/usr/bin/env bash
# =============================================================================
# IMPERATIVE deployment of Traefik + Keycloak-protected dashboard.
# Alternative without ArgoCD. For GitOps, see argocd/README.md (recommended).
# Run from the repo root after filling in the placeholders (see README.md).
# =============================================================================
set -euo pipefail

NS=traefik

echo ">> 1. Namespace (with Pod Security Admission label)"
oc create namespace "$NS" --dry-run=client -o yaml | oc apply -f -
oc label namespace "$NS" pod-security.kubernetes.io/enforce=restricted --overwrite

echo ">> 2. (Optional) MetalLB pool — uncomment if you need it"
# oc apply -f metallb/ipaddresspool.example.yaml

echo ">> 3. Traefik via Helm (official chart, pinned to the version in argocd/apps/traefik.yaml)"
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install traefik traefik/traefik \
  --version 41.0.2 \
  -n "$NS" -f helm/values-traefik.yaml

echo ">> 4. Dashboard TLS certificate (see docs/tls-secret.md)"
# oc create secret tls traefik-dashboard-tls -n "$NS" --cert=tls.crt --key=tls.key

echo ">> 5. oauth2-proxy Secret (copy secrets/oauth2-proxy-secret.example.yaml -> secrets/oauth2-proxy-secret.yaml)"
oc apply -f secrets/oauth2-proxy-secret.yaml

echo ">> 6. Dashboard manifests (oauth2-proxy + middlewares + IngressRoutes) via Kustomize"
oc apply -k manifests/

echo ">> 7. IP assigned by MetalLB to the traefik service:"
oc get svc traefik -n "$NS" -o wide

echo ">> Done. Point the DNS of traefik.apps.example.com to that IP and open https://traefik.apps.example.com/dashboard/"
