## Summary

<!-- What changes and why. Link the issue it closes, e.g. "Closes #123". -->

## Checklist

- [ ] The PR title follows Conventional Commits, e.g. `fix: ...`; it decides the release
- [ ] `scripts/smoke-test.sh` passes on a local build when nginx or the hosts change
- [ ] Hosts, port, `/healthz` or the image name change only together with the `mahahe-website` chart in mahahe-it/helm
