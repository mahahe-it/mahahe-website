---
title: Helm charts
---

# MaHaHe Helm charts

Applications ready to run on Kubernetes, published as OCI artifacts on GitHub
Container Registry: no `helm repo add` needed.

```bash
helm install my-release oci://ghcr.io/mahahe-it/helm/<chart>

# A specific version
helm install my-release oci://ghcr.io/mahahe-it/helm/<chart> --version <version>

# Inspect a chart before installing it
helm show values oci://ghcr.io/mahahe-it/helm/<chart>
```

## Charts

{{< charts >}}

Sources, issues and changelogs are on [GitHub](https://github.com/mahahe-it/helm).

## Deprecated HTTPS repository

Until 2026-04-20 the charts were published as an HTTPS repository at
`https://helm.mahahe.it`. It still answers, frozen at the 0.1.x releases, but
gets no new versions: switch to the `oci://` URLs above.
