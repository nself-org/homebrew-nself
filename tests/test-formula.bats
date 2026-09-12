#!/usr/bin/env bats
# test-formula.bats
# T-0396 — Homebrew formula validation
#
# Checks that the nself Homebrew formula is syntactically correct and well-formed.
#
# Two tiers of tests:
#   static  — file inspection only; no brew required; runs anywhere
#   brew    — requires brew in PATH; skipped otherwise
#
# Usage:
#   bats tests/test-formula.bats
#
# Override the formula path:
#   FORMULA_FILE=/path/to/nself.rb bats tests/test-formula.bats
#
# Override the nself binary (post-install verification):
#   NSELF_BIN=/usr/local/bin/nself bats tests/test-formula.bats

FORMULA_FILE="${FORMULA_FILE:-$(find "$(dirname "$BATS_TEST_DIRNAME")" -name "nself.rb" 2>/dev/null | head -1)}"
NSELF_BIN="${NSELF_BIN:-nself}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_require_brew() {
  command -v brew >/dev/null 2>&1 || skip "brew not found in PATH"
}

_require_nself() {
  command -v "$NSELF_BIN" >/dev/null 2>&1 || skip "nself not found in PATH"
}

# ---------------------------------------------------------------------------
# Static tier — file inspection; no brew required
# ---------------------------------------------------------------------------

@test "static: formula file exists" {
  [ -n "$FORMULA_FILE" ]
  [ -f "$FORMULA_FILE" ]
}

@test "static: formula has desc, homepage, url, sha256" {
  [ -f "$FORMULA_FILE" ]
  grep -q 'desc ' "$FORMULA_FILE"
  grep -q 'homepage ' "$FORMULA_FILE"
  grep -q 'url ' "$FORMULA_FILE"
  grep -q 'sha256 ' "$FORMULA_FILE"
}

@test "static: formula has install block" {
  [ -f "$FORMULA_FILE" ]
  grep -q 'def install' "$FORMULA_FILE"
}

@test "static: formula has test block" {
  [ -f "$FORMULA_FILE" ]
  # Homebrew DSL uses `test do` blocks, not `def test` method syntax
  grep -q 'test do' "$FORMULA_FILE"
}

# ---------------------------------------------------------------------------
# Dual-arch tier — the formula carries TWO sha256 values, one per architecture.
#
# Regression guard for the tap updater. nself-org/cli release.yml dispatches
# `cli-release` carrying a single `sha256` computed from the GitHub SOURCE
# archive. Both tap workflows used to sed that one value in with
#   sed -i 's|sha256 "[a-f0-9]*"|sha256 "$SHA"|'
# and sed without /g still substitutes once per LINE — so both the on_arm and
# on_intel sha256 lines were overwritten with the same, wrong hash, and
# `brew install nself` would fail its checksum on every Mac.
#
# Reproduced 2026-09-12: applying that sed to this formula matched 2 lines.
# These tests make the failure loud at PR time instead of at user install time.
# ---------------------------------------------------------------------------

_block_sha() {
  # $1 = arm|intel — read the sha256 from inside that on_* block only.
  awk -v want="$1" '
    /^[[:space:]]*on_arm do/        { block = "arm" }
    /^[[:space:]]*on_intel do/      { block = "intel" }
    /^[[:space:]]*end[[:space:]]*$/ { block = "" }
    block == want && /^[[:space:]]*sha256[[:space:]]*"/ {
      s = $0; sub(/.*sha256[[:space:]]*"/, "", s); sub(/".*/, "", s); print s; exit
    }
  ' "$FORMULA_FILE"
}

@test "static: formula has a sha256 in both the on_arm and on_intel blocks" {
  [ -f "$FORMULA_FILE" ]
  arm="$(_block_sha arm)"
  intel="$(_block_sha intel)"
  [ -n "$arm" ]
  [ -n "$intel" ]
}

@test "static: both arch sha256 values are well-formed 64-hex" {
  [ -f "$FORMULA_FILE" ]
  for v in "$(_block_sha arm)" "$(_block_sha intel)"; do
    printf '%s' "$v" | grep -qE '^[0-9a-f]{64}$'
  done
}

@test "static: the two arch sha256 values are NOT equal to each other" {
  # Two different binaries cannot share a hash. Equality here means a
  # single-value updater overwrote both lines. This is THE regression guard.
  [ -f "$FORMULA_FILE" ]
  arm="$(_block_sha arm)"
  intel="$(_block_sha intel)"
  if [ "$arm" = "$intel" ]; then
    printf 'on_arm and on_intel both carry %s\n' "$arm"
    printf 'A single-value sed overwrote both sha256 lines.\n'
    printf 'See .github/scripts/update-formula.sh for the per-block writer.\n'
    return 1
  fi
}

@test "static: no url points at the source archive (archive/refs/tags)" {
  # The companion half of the same bug: the old updater also rewrote url to
  # the source tarball. This formula installs pre-built darwin binaries.
  [ -f "$FORMULA_FILE" ]
  ! grep -qE '^[[:space:]]*url[[:space:]]*"[^"]*archive/refs/tags/' "$FORMULA_FILE"
}

@test "static: assert-dual-arch.sh agrees (offline tier)" {
  guard="$(dirname "$BATS_TEST_DIRNAME")/.github/scripts/assert-dual-arch.sh"
  [ -f "$guard" ] || skip "assert-dual-arch.sh not present"
  run bash "$guard" "$FORMULA_FILE"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Network tier — needs the release to be published
# ---------------------------------------------------------------------------

@test "network: neither arch sha256 equals the source-tarball hash" {
  # The source archive's hash is what the broken updater wrote. If it ever
  # appears in an arch block again, fail here.
  #
  # The formula legitimately precedes the release in this project's flow
  # (cli release.yml refuses to publish until the formula names the new
  # version), so an unpublished tag SKIPS rather than fails.
  command -v curl >/dev/null 2>&1 || skip "curl not available"
  guard="$(dirname "$BATS_TEST_DIRNAME")/.github/scripts/assert-dual-arch.sh"
  [ -f "$guard" ] || skip "assert-dual-arch.sh not present"
  CHECK_SOURCE_HASH=1 run bash "$guard" "$FORMULA_FILE"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Brew tier — requires brew in PATH
# ---------------------------------------------------------------------------

@test "brew: formula audit passes (requires brew)" {
  _require_brew
  [ -f "$FORMULA_FILE" ]
  run brew audit --strict "$FORMULA_FILE"
  # Exit 0 = no issues.
  # Non-zero with warnings only (no "Error:" lines) is also acceptable.
  case "$status" in
    0) ;;
    *)
      if printf '%s\n' "$output" | grep -qiE '^Error:'; then
        printf 'brew audit errors:\n%s\n' "$output"
        return 1
      fi
      ;;
  esac
}

@test "brew: nself --version works after install (requires brew + nself)" {
  _require_brew
  _require_nself
  run "$NSELF_BIN" --version
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+'
}
