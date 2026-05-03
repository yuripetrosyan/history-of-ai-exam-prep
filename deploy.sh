#!/bin/bash
# One-shot deployment to GitHub Pages via gh CLI
# Run this from inside the deploy/ folder.

set -e

REPO_NAME="history-of-ai-exam-prep"
DESCRIPTION="Interactive study platform for VU Amsterdam Bachelor AI History of AI exam."

echo "==> Initialising git repository..."
git init -b main 2>/dev/null || true
git add .
git diff --cached --quiet || git commit -m "Initial commit: History of AI exam prep platform"

echo "==> Creating GitHub repo and pushing..."
gh repo create "$REPO_NAME" \
  --public \
  --description "$DESCRIPTION" \
  --source=. \
  --remote=origin \
  --push

USERNAME=$(gh api user -q .login)
REPO_URL="https://github.com/${USERNAME}/${REPO_NAME}"

echo "==> Enabling GitHub Pages on main branch..."
gh api -X POST "repos/${USERNAME}/${REPO_NAME}/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/" \
  >/dev/null 2>&1 || echo "    (Pages may already be enabled or need manual setup — check ${REPO_URL}/settings/pages)"

echo ""
echo "✅ Done!"
echo ""
echo "    Repo:  ${REPO_URL}"
echo "    Site:  https://${USERNAME}.github.io/${REPO_NAME}/"
echo ""
echo "Pages takes ~1-2 minutes to build. Check the green checkmark on the repo's Actions tab."
