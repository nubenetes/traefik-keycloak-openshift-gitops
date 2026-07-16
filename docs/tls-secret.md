# Dashboard TLS certificate (`traefik-dashboard-tls`)

With MetalLB, **Traefik terminates TLS** (there is no OpenShift Route in front),
so it needs a `kubernetes.io/tls` Secret with the cert for `traefik.apps.example.com`.

It is managed **outside git** (out-of-band), NOT by ArgoCD — just like
`oauth2-proxy-secret`. With **cert-manager** (option A) it does become
declarative: the `Certificate` can live in git and cert-manager creates the
Secret on its own.

## Option A — cert-manager (recommended, GitOps-friendly)

If you have cert-manager + a ClusterIssuer, add this `Certificate` to
`manifests/` (and to `manifests/kustomization.yaml`) so ArgoCD manages it:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: traefik-dashboard-tls
  namespace: traefik
spec:
  secretName: traefik-dashboard-tls
  dnsNames:
    - traefik.apps.example.com
  issuerRef:
    name: YOUR_CLUSTERISSUER
    kind: ClusterIssuer
```

## Option B — existing cert (out-of-band)

```bash
oc create secret tls traefik-dashboard-tls \
  -n traefik \
  --cert=tls.crt --key=tls.key
```

## Option C — self-signed (testing only)

```bash
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout tls.key -out tls.crt -subj "/CN=traefik.apps.example.com"
oc create secret tls traefik-dashboard-tls -n traefik --cert=tls.crt --key=tls.key
```

> The browser will warn about the self-signed cert; the OIDC flow still works.
