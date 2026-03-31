#!/bin/bash
# KRILLIN VALIDATION — OMNIS-HARDEN-01
# Run this before EVERY public release.
# Every check must pass. One fail = BLOCK RELEASE.

set -e
echo "🔍 KRILLIN VALIDATION — OMNIS-HARDEN-01"
echo "========================================="

FAILED=0

check() {
  local desc="$1"
  local cmd="$2"
  local expect="$3"  # "zero" or "nonzero"
  
  if eval "$cmd" > /dev/null 2>&1; then
    result="pass"
  else
    result="fail"
  fi
  
  if [ "$expect" = "zero" ] && [ "$result" = "fail" ]; then
    echo "❌ FAIL: $desc"
    FAILED=$((FAILED+1))
  elif [ "$expect" = "nonzero" ] && [ "$result" = "pass" ]; then
    echo "❌ FAIL: $desc"
    FAILED=$((FAILED+1))
  else
    echo "✅ PASS: $desc"
  fi
}

# 1. No COSMIC logic in public repo
echo ""
echo "── Checking for proprietary logic leaks..."
check "No scoring weights in repo" \
  "grep -r 'score.*0\.[0-9].*=.*0\.[0-9]' src/ --include='*.ts' | grep -v integrations | grep -v '// '" \
  "nonzero"

check "No AURORA threshold logic in non-integration files" \
  "grep -r 'aurora.*threshold\|threshold.*aurora' src/ --include='*.ts' | grep -v integrations | grep -v config" \
  "nonzero"

check "No hardcoded API keys" \
  "! grep -rqE 'Bearer [a-zA-Z0-9]{20,}' --include='*.ts' --exclude='*.test.ts' src/ 2>/dev/null | grep -qv 'process.env'" \
  "zero"

# 2. Integration files are thin (no logic)
echo ""
echo "── Checking integration boundary..."
check "cosmic.ts exists" "test -f src/integrations/cosmic.ts" "zero"
check "aurora.ts exists" "test -f src/integrations/aurora.ts" "zero"
check "vellum.ts exists" "test -f src/integrations/vellum.ts" "zero"
check "luna.ts exists" "test -f src/integrations/luna.ts" "zero"

check "cosmic.ts calls API (not local)" \
  "grep -q 'api.omniskey.ai\|OMNIS_API_URL' src/integrations/cosmic.ts" \
  "zero"

check "aurora.ts calls API (not local)" \
  "grep -q 'api.omniskey.ai\|OMNIS_API_URL' src/integrations/aurora.ts" \
  "zero"

# 3. ENV-only auth
echo ""
echo "── Checking auth pattern..."
check "OMNIS_API_KEY via env only" \
  "grep -r 'OMNIS_API_KEY' src/integrations/ | grep -q 'process.env'" \
  "zero"

# 4. README has required warning
echo ""
echo "── Checking README warning..."
check "README has intelligence warning" \
  "grep -q 'NOT included' README.md" \
  "zero"

check "README has api.omniskey.ai reference" \
  "grep -q 'api.omniskey.ai' README.md" \
  "zero"

# 5. MIT license intact
echo ""
echo "── Checking license..."
check "MIT license present" \
  "grep -q 'MIT License' LICENSE" \
  "zero"

# Result
echo ""
echo "========================================="
if [ $FAILED -eq 0 ]; then
  echo "✅ ALL CHECKS PASSED — RELEASE APPROVED"
else
  echo "❌ $FAILED CHECK(S) FAILED — RELEASE BLOCKED"
  exit 1
fi
