[![CI](https://github.com/mahahe-it/mahahe-website/actions/workflows/ci.yaml/badge.svg)](https://github.com/mahahe-it/mahahe-website/actions/workflows/ci.yaml)
[![Release](https://github.com/mahahe-it/mahahe-website/actions/workflows/release.yaml/badge.svg)](https://github.com/mahahe-it/mahahe-website/actions/workflows/release.yaml)

# MaHaHe website

The [Hugo](https://gohugo.io) site behind [www.mahahe.it](https://www.mahahe.it),
including the [Helm charts](https://www.mahahe.it/helm/) page, shipped as a
container image:

```console
ghcr.io/mahahe-it/mahahe-website:<version>
```

It is deployed with the `mahahe-website` chart from
[mahahe-it/helm](https://github.com/mahahe-it/helm).

## What the image serves

nginx (unprivileged, uid 101) on plain HTTP port **8080**; TLS ends at the
Ingress. With a read-only root filesystem it needs a writable `/tmp`.

| Host | Serves |
|---|---|
| `www.mahahe.it` (and any other host) | The site; `GET /healthz` returns 200 |
| `helm.mahahe.it` | Only `/index.yaml` and `/*.tgz` of the frozen legacy HTTPS chart repository ([`static/legacy-helm/`](static/legacy-helm)); everything else is a 301 to `https://www.mahahe.it/helm/` |
| `mahahe.it` | 301 to `https://www.mahahe.it` |

The chart catalog on `/helm/` is read in the browser from the
[Artifact Hub](https://artifacthub.io/packages/search?org=mahahe-it) API, so new
charts and releases show up without rebuilding the site.

## Working on the site

The theme is a git submodule:

```console
git clone --recurse-submodules https://github.com/mahahe-it/mahahe-website.git
```

Preview with live reload (the Hugo version is the one in the `Dockerfile`):

```console
podman run --rm -it -v "$PWD":/project:Z,ro -p 1313:1313 \
  ghcr.io/gohugoio/hugo:<version> server --bind 0.0.0.0 \
  --renderToMemory --noBuildLock
```

Open <http://localhost:1313/>. The catalog on `/helm/` needs Internet access.

Build the image and check every host the way the chart runs it (read-only):

```console
podman build -t localhost/mahahe-website:dev .
scripts/smoke-test.sh localhost/mahahe-website:dev
```

CI runs the same build and smoke test on every pull request.

## Contributing and releases

Open a pull request against `main`. Its title must follow
[Conventional Commits](https://www.conventionalcommits.org): it becomes the
squash commit that [release-please](https://github.com/googleapis/release-please)
reads.

- `fix: ...` releases a patch version, `feat: ...` a minor one, a `!` after
  the type (`feat!: ...`) a major one.
- `docs:`, `ci:`, `chore:` and the other types release nothing.

Merging the release PR tags `v<version>`, creates the GitHub release and
pushes the image as `<version>` and `latest`. [Renovate](https://docs.renovatebot.com)
keeps Hugo, nginx and the theme up to date, as patch releases.

## License

[Apache License 2.0](LICENSE).

## Maintainers

The MaHaHe DevOps Team: [devops@mahahe.it](mailto:devops@mahahe.it).
