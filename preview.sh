#!/usr/bin/env bash
# Preview this wiki locally in the Docusaurus site (docloud-dev/docloud-docs-public).
#
#   ./preview.sh          sync docs/ and blog/, start the dev server, keep syncing edits
#   ./preview.sh build    sync once and run the production build (what the deploy runs)
#
# The site repo is expected next to this one; set SITE_DIR to use another path.
# It is cloned and installed on first run. The site repo gitignores docs/ and
# blog/, so the synced content stays out of its git status.

set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="${SITE_DIR:-$WIKI_DIR/../docloud-docs-public}"

if [ ! -d "$SITE_DIR" ]; then
  git clone https://github.com/docloud-dev/docloud-docs-public.git "$SITE_DIR"
fi
SITE_DIR="$(cd "$SITE_DIR" && pwd)"

if [ ! -x "$SITE_DIR/node_modules/.bin/docusaurus" ]; then
  (cd "$SITE_DIR" && npm install --no-audit --no-fund)
fi

# Mirrors the deploy workflow's "Sync Docs and Blog" step: the site's docs/ and
# blog/ become exact copies of the wiki's.
sync() {
  mkdir -p "$SITE_DIR/docs" "$SITE_DIR/blog"
  rsync -a --delete "$WIKI_DIR/docs/" "$SITE_DIR/docs/"
  rsync -a --delete "$WIKI_DIR/blog/" "$SITE_DIR/blog/"
}

sync
cd "$SITE_DIR"

case "${1:-start}" in
  build)
    npm run build
    ;;
  start)
    # Re-sync every second so edits here reach the dev server's hot reload.
    ( while sleep 1; do sync; done ) &
    trap 'kill $! 2>/dev/null' EXIT
    npm start
    ;;
  *)
    echo "usage: $0 [start|build]" >&2
    exit 1
    ;;
esac
