#!/bin/sh
set -eu

: "${REPO:?REPO must be set}"
: "${BRANCH:=main}"
: "${INTERVAL:=120}"
: "${HUGO_VERSION:=0.152.0}"

case "$(uname -m)" in
  aarch64|arm64) HUGO_ARCH="linux-arm64" ;;
  x86_64|amd64)  HUGO_ARCH="linux-amd64" ;;
  *) echo "[deploy] unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

echo "[deploy] starting - repo=$REPO branch=$BRANCH interval=${INTERVAL}s"

if ! command -v git >/dev/null 2>&1; then
  echo "[deploy] installing git and curl"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends git curl ca-certificates >/dev/null
fi

if ! /tools/hugo version 2>/dev/null | grep -q "v${HUGO_VERSION}"; then
  echo "[deploy] fetching hugo ${HUGO_VERSION} ${HUGO_ARCH}"
  mkdir -p /tools
  curl -sSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_${HUGO_ARCH}.tar.gz" | tar xz -C /tools hugo
  chmod +x /tools/hugo
  /tools/hugo version
fi

build() {
  if /tools/hugo --source /src --destination /out --gc --minify --cleanDestinationDir; then
    echo "[deploy] built $(date -u +%FT%TZ) $(git -C /src rev-parse --short HEAD)"
  else
    echo "[deploy] BUILD FAILED - previous output left in place" >&2
  fi
}

if [ ! -d /src/.git ]; then
  echo "[deploy] cloning"
  find /src -mindepth 1 -delete 2>/dev/null || true
  git clone --depth 1 --branch "$BRANCH" "$REPO" /src
  build
elif [ ! -f /out/index.html ]; then
  echo "[deploy] output empty, rebuilding"
  build
fi

while true; do
  sleep "$INTERVAL"
  git -C /src fetch --depth 1 --quiet origin "$BRANCH" 2>/dev/null || { echo "[deploy] fetch failed"; continue; }
  LOCAL="$(git -C /src rev-parse HEAD)"
  REMOTE="$(git -C /src rev-parse "origin/${BRANCH}")"
  if [ "$LOCAL" != "$REMOTE" ]; then
    echo "[deploy] change detected"
    git -C /src reset --hard --quiet "origin/${BRANCH}"
    build
  fi
done
