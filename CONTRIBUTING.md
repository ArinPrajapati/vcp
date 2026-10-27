# Contributing

Bug reports and small PRs are welcome.

- Keep it POSIX `sh`, with no dependencies beyond the standard tools.
- `sh test/test.sh` and `shellcheck bin/vcp test/test.sh install.sh uninstall.sh` must pass; CI runs both on Linux and macOS.
- Tests use a fake `vercel` binary. Never put real tokens or real account names in tests, issues or PRs.
- Behaviour changes need a test and a README line. Errors should say how to fix the problem (`fix:` line).
- Out of scope: team/org switching (the Vercel CLI does that), and anything that reads or prints `auth.json`.
