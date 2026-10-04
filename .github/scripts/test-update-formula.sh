#!/usr/bin/env bash
#
# test-update-formula.sh — fixture test for update-formula.sh. No network.
#
# Purpose:   Prove update-formula.sh writes each darwin hash into its own
#            on_arm / on_intel block, both from --checksums-file (release not
#            yet published) and from the default fetch path, and that a
#            checksums file missing a darwin asset is refused.
# Inputs:    none. Uses .github/scripts/fixtures/ (formula, checksums, archive).
# Outputs:   one PASS line per case; exit 0 when all pass, 1 on the first FAIL.
# Constraints:
#   - curl is replaced by a PATH stub: the release checksums URL answers 404
#     unless the case serves it, the source-archive URL serves the fixture
#     archive, anything else fails. The stub logs every URL it is asked for.
#   - Runs in a temp directory so the script's README.md step finds no README.
#
# SPORT: homebrew-nself / release automation / formula writer test

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
FIX="${HERE}/fixtures"
SCRIPT="${HERE}/update-formula.sh"
DUAL="${HERE}/assert-dual-arch.sh"

ARM='3c1f0b8e5d2a47c9a6e1f4b7d8c0a9e2b5f6d3c4a1e8b7f09c2d5a6e3b4f1c70'
AMD='9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d'

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "${WORK}/bin" "${WORK}/run"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

# curl stub. SERVE_CHECKSUMS=1 makes the release checksums URL answer.
cat > "${WORK}/bin/curl" <<'STUB'
#!/usr/bin/env bash
url=""
for a in "$@"; do url="$a"; done
printf '%s\n' "$url" >> "${STUB_LOG}"
case "$url" in
  */releases/download/*/checksums.txt)
    if [ "${SERVE_CHECKSUMS:-0}" = "1" ]; then cat "${STUB_CHECKSUMS}"; exit 0; fi
    exit 22 ;;
  */archive/refs/tags/*.tar.gz) cat "${STUB_ARCHIVE}"; exit 0 ;;
  *) exit 22 ;;
esac
STUB
chmod +x "${WORK}/bin/curl"

export PATH="${WORK}/bin:${PATH}"
export STUB_LOG="${WORK}/curl.log"
export STUB_CHECKSUMS="${FIX}/checksums.txt"
export STUB_ARCHIVE="${FIX}/source-archive.tar.gz"

block_sha() {
  awk -v want="$2" '
    /^[[:space:]]*on_arm do/        { block = "arm" }
    /^[[:space:]]*on_intel do/      { block = "intel" }
    /^[[:space:]]*end[[:space:]]*$/ { block = "" }
    block == want && /^[[:space:]]*sha256[[:space:]]*"/ {
      s = $0; sub(/.*sha256[[:space:]]*"/, "", s); sub(/".*/, "", s); print s; exit
    }
  ' "$1"
}

fresh_formula() { cp "${FIX}/nself.rb" "${WORK}/run/nself.rb"; : > "${STUB_LOG}"; }

assert_written() {
  [ "$(block_sha "${WORK}/run/nself.rb" arm)" = "$ARM" ] || fail "$1: arm64 hash not in on_arm"
  [ "$(block_sha "${WORK}/run/nself.rb" intel)" = "$AMD" ] || fail "$1: amd64 hash not in on_intel"
  grep -qE '^[[:space:]]*version "9\.9\.9"' "${WORK}/run/nself.rb" || fail "$1: version not written"
  bash "$DUAL" "${WORK}/run/nself.rb" >/dev/null || fail "$1: assert-dual-arch.sh rejected the result"
}

run_script() { (cd "${WORK}/run" && bash "$SCRIPT" --formula "${WORK}/run/nself.rb" "$@"); }

# Case 1: --checksums-file, release URL 404s, no network for checksums.
fresh_formula
unset SERVE_CHECKSUMS || true
run_script --version v9.9.9 --checksums-file "${FIX}/checksums.txt" >"${WORK}/out1" 2>&1 \
  || { cat "${WORK}/out1" >&2; fail "case 1: exit non-zero"; }
assert_written "case 1"
! grep -q 'releases/download' "${STUB_LOG}" || fail "case 1: fetched the release checksums despite --checksums-file"
grep -q 'archive/refs/tags/v9.9.9.tar.gz' "${STUB_LOG}" || fail "case 1: source-archive guard did not run"
pass "--checksums-file writes arm64 into on_arm and amd64 into on_intel (release URL never fetched)"

# Case 2: default path unchanged, checksums fetched from the release URL.
fresh_formula
SERVE_CHECKSUMS=1 run_script --version 9.9.9 >"${WORK}/out2" 2>&1 \
  || { cat "${WORK}/out2" >&2; fail "case 2: exit non-zero"; }
assert_written "case 2"
grep -q 'releases/download/v9.9.9/checksums.txt' "${STUB_LOG}" || fail "case 2: did not fetch the release checksums"
pass "default fetch path unchanged"

# Case 3: a checksums file missing a darwin asset is refused, formula untouched.
fresh_formula
cp "${WORK}/run/nself.rb" "${WORK}/before.rb"
if run_script --version v9.9.9 --checksums-file "${FIX}/checksums-no-amd64.txt" >"${WORK}/out3" 2>&1; then
  fail "case 3: exited 0 for a checksums file without darwin-amd64"
else
  rc=$?
fi
[ "$rc" -eq 1 ] || fail "case 3: exit code $rc, want 1"
grep -q 'no valid sha256 for nself-9.9.9-darwin-amd64.tar.gz' "${WORK}/out3" || fail "case 3: missing the existing error message"
cmp -s "${WORK}/run/nself.rb" "${WORK}/before.rb" || fail "case 3: formula was modified"
pass "checksums file without a darwin asset exits 1 with the existing message"

# Case 4: missing and empty checksums files are refused.
fresh_formula
if run_script --version v9.9.9 --checksums-file "${WORK}/nope.txt" >"${WORK}/out4" 2>&1; then
  fail "case 4: exited 0 for a missing checksums file"
fi
grep -q 'checksums-file not found' "${WORK}/out4" || fail "case 4: no 'not found' message"
: > "${WORK}/empty.txt"
if run_script --version v9.9.9 --checksums-file "${WORK}/empty.txt" >"${WORK}/out4b" 2>&1; then
  fail "case 4: exited 0 for an empty checksums file"
fi
grep -q 'checksums-file is empty' "${WORK}/out4b" || fail "case 4: no 'empty' message"
pass "missing and empty --checksums-file are refused"

# Case 5: re-running with the same input is idempotent.
fresh_formula
run_script --version v9.9.9 --checksums-file "${FIX}/checksums.txt" >/dev/null 2>&1 || fail "case 5: first run failed"
run_script --version v9.9.9 --checksums-file "${FIX}/checksums.txt" >"${WORK}/out5" 2>&1 || fail "case 5: second run failed"
grep -q 'SKIP' "${WORK}/out5" || fail "case 5: second run did not skip"
pass "idempotent on a formula already at the target"

printf 'all update-formula.sh cases passed\n'
