#!/bin/sh
# ---------------------------------------------------------------------------
# Pulls the site repo on a timer and rebuilds it with Hugo.
#
# No webhooks, no CI secrets, nothing that expires. An agent pushes a markdown
# file to the repo and the post is live within $INTERVAL seconds.
# ---------------------------------------------------------------------------
set -eu

: "${REPO:?REPO must be set (e.g. https://github.com/you/site.git)}"
: "${BRANCH:=main}"
: "${INTERVAL:=120}"
: "${HUGO_VERSION:=0.152.0}"

ARCH="$(uname -m)"
case "$ARCH" in
  aarch64|arm64) HUGO_ARCH="linux-arm64" ;;
  x86_64|amd64)  HUGO_ARCH="linux-amd64" ;;
  *) echo "[deploy] unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

echo "[deploy] starting — repo=$REPO branch=$BRANCH interval=${INTERVAL}s"

# --- dependencies ----------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
  apk add --no-cache git curl ca-certificates >/dev/null
fi

# --- hugo (pinned, cached in the tools volume) -----------------------------
if [ ! -x /tools/hugo ] || [ "$(/tools/hugo version 2>/dev/null | grep -c "v${HUGO_VERSION}")" -eq 0 ]; then
  echo "[deploy] fetching hugo ${HUGO_VERSION} (${HUGO_ARCH})"
  mkdir -p /tools
  curl -sSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_${HUGO_ARCH}.tar.gz" \
    | tar xz -C /tools hugo
  chmod +x /tools/hugo
fi

build() {
  /tools/hugo --source /src --destination /out --gc --minify --cleanDestinationDir
  echo "[deploy] built $(date -u +%FT%TZ) — $(git -C /src rev-parse --short HEAD)"
}

# --- first run -------------------------------------------------------------
if [ ! -d /src/.git ]; then
  echo "[deploy] cloning"
  rm -rf /src
  git clone --depth 1 --branch "$BRANCH" "$REPO" /src
  build
fi

# --- poll loop -------------------------------------------------------------
while true; do
  sleep "$INTERVAL"

  if ! git -C /src fetch --quiet origin "$BRANCH" 2>/dev/null; then
    echo "[deploy] fetch failed, will retry"
    continue
  fi

  LOCAL="$(git -C /src rev-parse HEAD)"
  REMOTE="$(git -C /src rev-parse "origin/${BRANCH}")"

  if [ "$LOCAL" != "$REMOTE" ]; then
    echo "[deploy] change detected: ${LOCAL%${LOCAL#???????}} -> ${REMOTE%${REMOTE#???????}}"
    git -C /src reset --hard --quiet "origin/${BRANCH}"
    if build; then
      :
    else
      echo "[deploy] BUILD FAILED — keeping previous output live" >&2
    fi
  fi
done
