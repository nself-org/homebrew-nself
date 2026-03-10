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
  grep -q 'def test' "$FORMULA_FILE"
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
