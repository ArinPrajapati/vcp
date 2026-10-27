#!/bin/sh
# Tests vcp against a fake `vercel` that echoes its args. No network, no real login.
set -u
HERE=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/real" "$T/proj/sub"
cat > "$T/real/vercel" <<'F'
#!/bin/sh
echo "FAKE $*"
F
chmod +x "$T/real/vercel"
export VCP_HOME="$T/profiles" HOME="$T/home" VCP_QUIET=1
mkdir -p "$HOME"
export PATH="$HERE/bin:$T/real:/usr/bin:/bin"
unset VERCEL_PROFILE VERCEL_TOKEN
fails=0
check() { # check <desc> <expected-substring> <actual>
  case "$3" in *"$2"*) echo "ok   $1" ;; *) echo "FAIL $1: wanted '$2' in '$3'"; fails=$((fails+1)) ;; esac
}
mkdir -p "$VCP_HOME/personal" "$VCP_HOME/work"

out=$(vcp use personal); check "use sets default" "personal" "$out"
out=$(cd "$T/proj" && vercel whoami); check "global default passes --global-config" "--global-config $VCP_HOME/personal whoami" "$out"
out=$(cd "$T/proj" && vc ls); check "vc alias works" "$VCP_HOME/personal ls" "$out"
(cd "$T/proj" && vcp pin work >/dev/null)
out=$(cd "$T/proj/sub" && vercel whoami); check "pin found from subdir" "$VCP_HOME/work" "$out"
out=$(cd "$T/proj/sub" && VERCEL_PROFILE=personal vercel whoami); check "env var beats pin" "$VCP_HOME/personal" "$out"
out=$(cd "$T" && vercel whoami); check "outside pin uses global" "$VCP_HOME/personal" "$out"
out=$(vcp as work whoami); check "vcp as" "$VCP_HOME/work whoami" "$out"
out=$(vercel --token abc whoami); check "explicit --token respected" "FAKE --token abc whoami" "$out"
out=$(VERCEL_TOKEN=x vercel whoami); check "VERCEL_TOKEN respected" "FAKE whoami" "$out"
out=$(vercel -Q /x whoami); check "explicit -Q respected" "FAKE -Q /x whoami" "$out"
out=$(vcp use nope 2>&1); check "unknown profile errors with fix" "fix: run: vcp add nope" "$out"
out=$(vcp add 'Bad Name' 2>&1); check "bad name rejected" "invalid profile name" "$out"
out=$(cd "$T/proj" && vcp current); check "current shows source" "work (from $T/proj/.vercel-profile)" "$out"
out=$(vcp ls); check "ls lists both" "work" "$out"
mkdir -p "$HOME/Library/Application Support/com.vercel.cli"; echo '{}' > "$HOME/Library/Application Support/com.vercel.cli/auth.json"
vcp import imported >/dev/null
if [ -f "$VCP_HOME/imported/auth.json" ]; then echo "ok   import copies login"; else echo "FAIL import"; fails=$((fails+1)); fi
if [ -f "$HOME/Library/Application Support/com.vercel.cli/auth.json" ]; then echo "ok   import leaves original"; else echo "FAIL import removed original"; fails=$((fails+1)); fi
vcp rm imported >/dev/null
if [ ! -d "$VCP_HOME/imported" ]; then echo "ok   rm"; else echo "FAIL rm"; fails=$((fails+1)); fi
out=$(VCP_QUIET='' vercel deploy 2>&1 >/dev/null); check "deploy prints profile banner" "vcp: profile personal" "$out"
if [ "$fails" -eq 0 ]; then echo "ALL PASS"; else echo "$fails FAILED"; exit 1; fi
