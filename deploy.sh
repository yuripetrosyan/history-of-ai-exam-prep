#!/bin/bash
# Idempotent deployment to GitHub Pages via gh CLI.
# Safe to re-run.

set -e

REPO_NAME="history-of-ai-exam-prep"
DESCRIPTION="Interactive study platform for VU Amsterdam Bachelor AI History of AI exam."

echo "==> Initialising git repository..."
git init -b main 2>/dev/null || true
git add .
git diff --cached --quiet || git commit -m "Deploy: History of AI exam prep platform"

echo "==> Resolving GitHub user..."
USERNAME=$(gh api user -q .login)
REPO_URL="https://github.com/${USERNAME}/${REPO_NAME}"

echo "==> Ensuring remote 'origin' is set..."
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "${REPO_URL}.git"
else
  git remote add origin "${REPO_URL}.git"
fi

echo "==> Ensuring repo exists on GitHub..."
if gh repo view "${USERNAME}/${REPO_NAME}" >/dev/null 2>&1; then
  echo "    Repo already exists — skipping create."
else
  gh repo create "${USERNAME}/${REPO_NAME}" \
    --public \
    --description "$DESCRIPTION"
fi

echo "==> Pushing to main..."
git push -u origin main

echo "==> Enabling GitHub Pages on main / root..."
if gh api "repos/${USERNAME}/${REPO_NAME}/pages" >/dev/null 2>&1; then
  echo "    Pages already enabled — skipping."
else
  gh api -X POST "repos/${USERNAME}/${REPO_NAME}/pages" \
    -f "source[branch]=main" \
    -f "source[path]=/" \
    >/dev/null
  echo "    Pages enabled."
fi

echo ""
echo "✅ Done!"
echo ""
echo "    Repo:  ${REPO_URL}"
echo "    Site:  https://${USERNAME}.github.io/${REPO_NAME}/"
echo ""
echo "Pages typically takes 1-2 minutes to build on first deploy."
echo "Build status: ${REPO_URL}/actions"
