#!/usr/bin/env bash
# Run the image as the chart does (read-only root, writable /tmp) and check
# every host and path of the contract with the chart.
#
#   scripts/smoke-test.sh <image> [port]
#
# Uses podman when available, docker otherwise (ENGINE=... to choose).
set -euo pipefail

image=${1:?usage: $0 <image> [port]}
port=${2:-18080}
engine=${ENGINE:-$(command -v podman >/dev/null && echo podman || echo docker)}
name=mahahe-website-smoke-$$

"$engine" run -d --name "$name" --read-only --tmpfs /tmp -p "127.0.0.1:$port:8080" "$image" >/dev/null
trap '"$engine" rm -f "$name" >/dev/null' EXIT

for _ in $(seq 50); do
  [[ $(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/healthz") == 200 ]] && break
  sleep 0.2
done

failed=0
# check <host> <path> <expected "status[ location]">
check() {
  local got
  got=$(curl -s -o /dev/null -H "Host: $1" -w '%{http_code} %header{location}' "http://127.0.0.1:$port$2")
  got=${got% }
  if [[ $got == "$3" ]]; then
    printf 'ok    %-15s %-40s %s\n' "$1" "$2" "$got"
  else
    printf 'FAIL  %-15s %-40s %s (want %s)\n' "$1" "$2" "$got" "$3"
    failed=1
  fi
}

check www.mahahe.it  /           200
check www.mahahe.it  /helm/      200
check www.mahahe.it  /helm       "301 /helm/"
check www.mahahe.it  /healthz    200
check www.mahahe.it  /not-there  404
check 10.0.0.1       /healthz    200

check helm.mahahe.it /index.yaml 200
for tgz in static/legacy-helm/*.tgz; do
  check helm.mahahe.it "/${tgz##*/}" 200
done
check helm.mahahe.it /           "301 https://www.mahahe.it/helm/"
check helm.mahahe.it /x/y.tgz    "301 https://www.mahahe.it/helm/"
check helm.mahahe.it /healthz    200

check mahahe.it      "/helm/?a=1" "301 https://www.mahahe.it/helm/?a=1"

if (( failed )); then
  "$engine" logs "$name" 2>&1 | tail -20
  exit 1
fi
