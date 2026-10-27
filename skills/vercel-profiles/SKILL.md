---
name: vercel-profiles
description: Use whenever running any `vercel`/`vc` CLI command on this Mac (deploy, env, link, whoami, domains, logs). The user has two personal Vercel accounts managed by the `vcp` wrapper; check which profile is in effect before any link, deploy or env change. Also use when asked to switch or add a Vercel account.
---

# Vercel profiles (vcp)

The user has separate personal Vercel accounts, not teams. `vercel` and `vc` on PATH are shims from `~/.config/vcp/bin` that select an account by passing `--global-config ~/.vercel-profiles/<name>/` to the real CLI. List them with `vcp ls`.

## Before any consequential vercel command
1. Run `vcp current` from the target directory. It prints the profile and why (env, `.vercel-profile` file, or global).
2. If the project is meant for the other account, STOP and tell the user. Don't switch the global default (`vcp use`) on your own, because it affects every terminal. Use a one-off `vcp as <name> <args>` or `VERCEL_PROFILE=<name> vercel ...` instead, and only after the user confirms the target.
3. Combine with the vercel-cli skill's `vercel project inspect --non-interactive` check: the profile decides the account, the link decides the project. A repo's `.vercel/project.json` belongs to whichever account ran `vercel link`; a profile mismatch shows up as "project not found" or a scope error. Fix by pinning, not by relinking.

## Commands
- `vcp ls`, `vcp current`, `vcp whoami`, `vcp doctor`
- `vcp as <name> <vercel args>`: one-off as another profile
- `vcp pin [name]` / `vcp unpin`: per-repo `.vercel-profile` (ask before writing it)
- `vcp use <name>`: global default (ask first)
- `vcp add <name>`: creates a profile and starts `vercel login`, which is interactive and opens a browser. Ask the user to run it themselves, e.g. with `! vcp add work`.

## Rules
- Never read or print `~/.vercel-profiles/*/auth.json` (tokens). Never pass `--token` on the command line; the shim steps aside if you do.
- Deploy-like commands print `vcp: profile X (...)` on stderr. Report that profile in your summary when you deploy.
- If `vercel` doesn't resolve to `~/.config/vcp/bin/vercel` (`vcp doctor`), PATH is wrong. Don't work around it by calling the pnpm binary directly, since that bypasses profiles and uses the old default login.
- Docs and tests: `~/.config/vcp/README.md`, `sh ~/.config/vcp/test/test.sh`.
