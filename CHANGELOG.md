# Changelog

## 0.1.0 — 2026-05-14

Initial release.

- `goto` — arrow-key picker for project bookmarks (powered by `gum`).
- `goto <name>` — direct jump.
- `goto add` / `goto list` / `goto rm` — manage bookmarks.
- `goto init` — wire `goto` into the user's shell rc file (idempotent).
- `-c` flag — launch `claude` in the destination directory.
- Bookmarks stored in `~/.goto-projects` (overridable via `GOTODIR_STORE`).
