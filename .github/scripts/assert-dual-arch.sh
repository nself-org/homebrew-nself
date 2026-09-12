#!/usr/bin/env bash
#
# assert-dual-arch.sh — fail if the dual-arch formula's two sha256 values have
# collapsed into one, or if either points at the source archive.
#
# Purpose:   Catch the class of bug where a formula updater writes ONE hash into
#            a formula that needs two. Cheap, offline, and safe to run anywhere.
# Inputs:    $1 — formula path (default: Formula/nself.rb)
#            NSELF_SOURCE_REPO — override the cli repo (default: nself-org/cli)
# Outputs:   Exit 0 if the formula is well-formed; non-zero with a diagnosis.
# Constraints:
#            Offline by default. Set CHECK_SOURCE_HASH=1 to additionally fetch
#            the source archive for the formula's version and assert neither
#            sha256 equals it; that check SKIPS (exit 0) if the tag is not
#            published yet, because the formula legitimately precedes the
#            release in this project's flow.
#
# WHY: nself-org/cli release.yml dispatches cli-release with a `sha256` payload
# computed from the GitHub source archive. Both tap workflows used to sed that
# single value into the formula, and sed without /g still fires once per line —
# so both the on_arm and on_intel sha256 lines received the same, wrong hash and
# `brew install nself` failed its checksum on every Mac. These assertions are
# what make that recurrence loud instead of silent.
#
# SPORT: homebrew-nself / release automation / formula guard

set -euo pipefail

FORMULA="${1:-Formula/nself.rb}"
SOURCE_REPO="${NSELF_SOURCE_REPO:-nself-org/cli}"

[ -f "$FORMULA" ] || { printf 'ERROR: formula not found: %s\n' "$FORMULA" >&2; exit 1; }

block_sha() {
  awk -v want="$1" '
    /^[[:space:]]*on_arm do/        { block = "arm" }
    /^[[:space:]]*on_intel do/      { block = "intel" }
    /^[[:space:]]*end[[:space:]]*$/ { block = "" }
    block == want && /^[[:space:]]*sha256[[:space:]]*"/ {
      s = $0; sub(/.*sha256[[:space:]]*"/, "", s); sub(/".*/, "", s); print s; exit
    }
  ' "$FORMULA"
}

ARM="$(block_sha arm)"
AMD="$(block_sha intel)"

fail() { printf '::error::%s\n' "$1" >&2; printf 'ERROR: %s\n' "$1" >&2; exit 1; }

[ -n "$ARM" ] || fail "no sha256 found inside the on_arm block of ${FORMULA}"
[ -n "$AMD" ] || fail "no sha256 found inside the on_intel block of ${FORMULA}"

printf '%s' "$ARM" | grep -qE '^[0-9a-f]{64}$' || fail "on_arm sha256 is not 64 hex chars: '${ARM}'"
printf '%s' "$AMD" | grep -qE '^[0-9a-f]{64}$' || fail "on_intel sha256 is not 64 hex chars: '${AMD}'"

if [ "$ARM" = "$AMD" ]; then
  fail "on_arm and on_intel carry the SAME sha256 (${ARM}).
  Two different binaries cannot share a hash. This is the signature of a
  single-value updater (sed without per-block targeting) overwriting both
  lines — see .github/scripts/update-formula.sh. brew install would fail
  the checksum on at least one architecture."
fi

# Both urls must point at the release binaries, never the source archive.
if grep -qE '^[[:space:]]*url[[:space:]]*"[^"]*archive/refs/tags/' "$FORMULA"; then
  fail "a url in ${FORMULA} points at archive/refs/tags/ (the source tarball).
  This formula installs pre-built darwin binaries from releases/download/."
fi

printf 'OK  on_arm  %s\n' "$ARM"
printf 'OK  on_intel %s\n' "$AMD"
printf 'OK  the two sha256 values are distinct\n'

if [ "${CHECK_SOURCE_HASH:-0}" != "1" ]; then
  exit 0
fi

VERSION="$(grep -E '^[[:space:]]*version[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' "$FORMULA" \
           | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
[ -n "$VERSION" ] || fail "could not read version from ${FORMULA}"

SRC_URL="https://github.com/${SOURCE_REPO}/archive/refs/tags/v${VERSION}.tar.gz"
CODE="$(curl -sIL -o /dev/null -w '%{http_code}' "$SRC_URL" || echo 000)"
if [ "$CODE" = "404" ]; then
  printf '::notice::v%s is not published yet — source-hash cross-check skipped\n' "$VERSION"
  exit 0
fi

if command -v sha256sum >/dev/null 2>&1; then
  SRC_SHA="$(curl -fsSL "$SRC_URL" | sha256sum | awk '{print $1}')"
else
  SRC_SHA="$(curl -fsSL "$SRC_URL" | shasum -a 256 | awk '{print $1}')"
fi

if ! printf '%s' "$SRC_SHA" | grep -qE '^[0-9a-f]{64}$'; then
  printf '::warning::could not compute the source-archive hash; cross-check skipped\n'
  exit 0
fi

if [ "$ARM" = "$SRC_SHA" ] || [ "$AMD" = "$SRC_SHA" ]; then
  fail "a formula sha256 equals the SOURCE archive hash (${SRC_SHA}).
  The source tarball's hash was written where a darwin binary's hash belongs.
  That is exactly the bug the sed-based updater produced."
fi

printf 'OK  neither sha256 matches the source archive (%s)\n' "${SRC_SHA:0:12}..."
