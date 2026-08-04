#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
branch="${1:-gh-pages}"
build_dir="$repo_root/dist"
worktree_dir="$(mktemp -d)"

cleanup() {
  git -C "$repo_root" worktree remove --force "$worktree_dir" >/dev/null 2>&1 || true
  rm -rf "$worktree_dir"
}
trap cleanup EXIT

cd "$repo_root"
npm run build

if git show-ref --verify --quiet "refs/heads/$branch"; then
  git worktree add --force "$worktree_dir" "$branch"
else
  git worktree add --force "$worktree_dir" --detach
  git -C "$worktree_dir" switch --orphan "$branch"
fi

find "$worktree_dir" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$build_dir"/. "$worktree_dir"/

git -C "$worktree_dir" add -A

if git -C "$worktree_dir" diff --cached --quiet; then
  echo "No Pages changes to commit."
else
  git -C "$worktree_dir" commit -m "Deploy GitHub Pages"
fi

git -C "$worktree_dir" push origin "$branch"