#!/bin/sh
# Install vcp: clones (or updates) the repo, then puts its bin dir first on PATH
# in your shell rc files. Safe to run twice.
#   curl -fsSL https://raw.githubusercontent.com/ArinPrajapati/vcp/main/install.sh | sh
set -eu

REPO="${VCP_REPO:-https://github.com/ArinPrajapati/vcp.git}"
DIR="${VCP_INSTALL_DIR:-$HOME/.config/vcp}"
BEGIN="# >>> vcp >>>"
END="# <<< vcp <<<"

say() { printf 'vcp-install: %s\n' "$1"; }

# 1. Get the code. If run from a clone, use that clone in place.
HERE=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || HERE=""
if [ -n "$HERE" ] && [ -x "$HERE/bin/vcp" ] && [ "$HERE" != "$DIR" ] && [ ! -e "$DIR" ]; then
  mkdir -p "$(dirname "$DIR")"
  ln -s "$HERE" "$DIR"
  say "linked $DIR -> $HERE"
elif [ -d "$DIR/.git" ]; then
  say "updating $DIR"
  git -C "$DIR" pull --ff-only
elif [ -e "$DIR" ]; then
  say "$DIR exists and is not a git clone; leaving it alone"
else
  command -v git >/dev/null 2>&1 || { say "git is required (or clone the repo yourself and run ./install.sh)"; exit 1; }
  git clone --depth 1 "$REPO" "$DIR"
fi
[ -x "$DIR/bin/vcp" ] || { say "$DIR/bin/vcp not found"; exit 1; }

# 2. PATH block, appended once, in each rc file that exists (zsh and bash).
add_block() {
  rc=$1
  if [ -f "$rc" ] && grep -qF "$BEGIN" "$rc"; then say "already set up in $rc"; return; fi
  # shellcheck disable=SC2016  # $PATH must stay literal in the rc file
  printf '\n%s\nexport PATH="%s/bin:$PATH"\n%s\n' "$BEGIN" "$DIR" "$END" >> "$rc"
  say "added PATH block to $rc"
}
touched=0
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
  [ -f "$rc" ] && { add_block "$rc"; touched=1; }
done
# zsh runs .zshenv for scripts and agents too; keep non-interactive shells on the shim.
if [ -f "$HOME/.zshrc" ] || [ "${SHELL##*/}" = "zsh" ]; then add_block "$HOME/.zshenv"; touched=1; fi
[ "$touched" -eq 1 ] || say "no shell rc found. Add this yourself: export PATH=\"$DIR/bin:\$PATH\""

# 3. Preflight and next steps.
PATH_WITHOUT=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vxF "$DIR/bin" | paste -sd: -)
if ! PATH="$PATH_WITHOUT" command -v vercel >/dev/null 2>&1; then
  say "warning: the real Vercel CLI was not found. Install it: npm i -g vercel"
fi
cat <<MSG

vcp is installed. Open a new terminal, then:

  vcp import me      # adopt your current Vercel login as profile "me"
  vcp add work       # or log in another account as "work"
  vcp doctor         # check everything
  fish users: fish_add_path -m $DIR/bin

MSG
