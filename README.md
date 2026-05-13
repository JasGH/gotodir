# gotodir

> Jump between your project directories with an arrow-key picker. One letter to bookmark, one keystroke to fly.

`gotodir` adds a `goto` command to your shell. Bookmark project paths once, then `goto` opens an arrow-key picker (powered by [`gum`](https://github.com/charmbracelet/gum)) and `cd`s you in.

```
$ goto
Select project:
  ◉ api
    web
    infra
    docs
```

## Why

Because `cd ~/work/clients/acme/2026/api-rewrite` ten times a day is the kind of thing computers should remember for you. `gotodir` is ~150 lines of POSIX shell — no Rust binary, no daemon, no shell history scanning, no magic. Just a flat file of bookmarks at `~/.goto-projects`.

## Install

```sh
brew tap JasGH/gotodir
brew install gotodir
```

Then add this line to your shell config:

```sh
# ~/.zshrc  (or ~/.bashrc)
[ -f "$(brew --prefix)/share/gotodir/gotodir.sh" ] && \
  source "$(brew --prefix)/share/gotodir/gotodir.sh"
```

Reload your shell:

```sh
source ~/.zshrc   # or open a new terminal
```

**That's it.** `brew` pulls in `gum` automatically — no other manual installs.

## Quickstart

```sh
cd ~/work/acme-api
goto add api              # bookmark current dir as "api"

cd ~/work/acme-web
goto add web              # bookmark current dir as "web"

goto                      # arrow-key picker → cd
goto api                  # jump directly
goto -c api               # jump, then launch `claude`
```

## Commands

| Command | What it does |
|---|---|
| `goto` | Open arrow-key picker, `cd` into the chosen project. |
| `goto <name>` | `cd` directly to the bookmark named `<name>`. |
| `goto add <name> [path]` | Bookmark `path` (defaults to current dir) as `<name>`. |
| `goto list` | Print all bookmarks as `name<TAB>path` lines. |
| `goto rm <name>` | Remove a bookmark. |
| `goto -c [name]` | Same as above, then run `claude` in the destination. |
| `goto --help` | Show help. |

### The `-c` flag

`-c` is a shorthand for "jump there and start a [Claude Code](https://claude.com/claude-code) session." It works with both the picker (`goto -c`) and direct jumps (`goto -c <name>`). If you don't have `claude` installed, leave the flag off — the rest of `gotodir` doesn't depend on it.

## Where data lives

Bookmarks are stored in plain text at:

```
~/.goto-projects
```

Format is one `name=/absolute/path` per line. Edit by hand if you like — sorting, bulk-rename with `sed`, syncing across machines via Dropbox/git, all fine.

Override the location with `GOTODIR_STORE`:

```sh
export GOTODIR_STORE="$HOME/Sync/goto-projects"
```

## Upgrade

```sh
brew update && brew upgrade gotodir
```

## Uninstall

```sh
brew uninstall gotodir
brew untap JasGH/gotodir
# remove the `source ...` line from ~/.zshrc
# optionally:  rm ~/.goto-projects
```

## Troubleshooting

**`goto: command not found`** — You skipped the `source` step. Add the line from [Install](#install) to your shell config and reload.

**`gotodir: 'gum' not found`** — Run `brew install gum` (or reinstall `gotodir`, which depends on it).

**Picker doesn't render properly** — Your terminal may not support the cursor character. Set a simpler one by editing the script, or open an issue.

**Bookmark survives `goto rm`** — Check `cat ~/.goto-projects`; you may have duplicates from hand-edits. Names should be unique.

## Contributing

Issues and PRs welcome at [github.com/JasGH/gotodir](https://github.com/JasGH/gotodir). The whole tool is two short shell files:

- `bin/gotodir` — the resolver (POSIX `sh`)
- `share/gotodir/gotodir.sh` — the `goto` shell function (bash/zsh)

## License

MIT — see [LICENSE](LICENSE).
