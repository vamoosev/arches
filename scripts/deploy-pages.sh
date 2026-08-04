#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
branch="main"
deploy_dir_name="docs"
build_dir="$repo_root/dist"
deploy_dir="$repo_root/$deploy_dir_name"

cd "$repo_root"
npm run build

current_branch="$(git branch --show-current)"

if [ "$current_branch" != "$branch" ]; then
  echo "Checkout '$branch' before deploying."
  exit 1
fi

rm -rf "$deploy_dir"
mkdir -p "$deploy_dir"
cp -R "$build_dir"/. "$deploy_dir"/
touch "$deploy_dir/.nojekyll"

git add "$deploy_dir_name"

if git diff --cached --quiet; then
  echo "No Pages changes to commit."
else
  git commit -m "Deploy GitHub Pages"
fi

git push origin "$branch"