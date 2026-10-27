#!/bin/sh
# Remove vcp's PATH blocks. Profiles (your logins) are kept unless you pass --purge.
set -eu
BEGIN="# >>> vcp >>>"
END="# <<< vcp <<<"
for rc in "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.bashrc" "$HOME/.bash_profile"; do
  [ -f "$rc" ] || continue
  grep -qF "$BEGIN" "$rc" || continue
  tmp=$(mktemp)
  awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1;next} $0==e{skip=0;next} !skip' "$rc" > "$tmp"
  cat "$tmp" > "$rc"; rm -f "$tmp"
  echo "uninstall: cleaned $rc"
done
if [ "${1:-}" = "--purge" ]; then
  rm -rf "${VCP_HOME:-$HOME/.vercel-profiles}"
  echo "uninstall: deleted all profiles (those logins are gone)"
else
  echo "uninstall: profiles kept in ${VCP_HOME:-$HOME/.vercel-profiles} (use --purge to delete)"
fi
echo "uninstall: delete ${VCP_INSTALL_DIR:-$HOME/.config/vcp} yourself if you want the code gone"
