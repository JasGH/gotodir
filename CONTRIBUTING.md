# Contributing to gotodir

`gotodir` is two short shell files:

- `bin/gotodir` — POSIX `sh` resolver (the subcommands)
- `share/gotodir/gotodir.sh` — the `goto` shell function (bash/zsh)

The local development loop doesn't require `brew install` — you source
the function directly from your checkout and put the local `bin/` on
`$PATH`. Edits to either file are picked up immediately (or after one
`exec zsh`).

## Local dev setup

> Replace `$HOME/Projects/gotodir` below with wherever you cloned the repo.

Add these two blocks to your `~/.zshrc` (or `~/.bashrc`):

```sh
# gotodir dev mode: use the local checkout's binary
export PATH="$HOME/Projects/gotodir/bin:$PATH"

# Source the shell function from the checkout
[ -f "$HOME/Projects/gotodir/share/gotodir/gotodir.sh" ] && \
  source "$HOME/Projects/gotodir/share/gotodir/gotodir.sh"
```

Reload your shell:

```sh
exec zsh
```

Verify:

```sh
which gotodir   # → <checkout>/bin/gotodir
type goto       # → shell function from <checkout>/share/gotodir/gotodir.sh
goto version    # → 0.1.0
```

If you also have `gotodir` installed via `brew`, the PATH line above
puts the dev binary first — your edits win. Remove that line to fall
back to the brew copy.

## Edit / test loop

- **`bin/gotodir`** — changes take effect on the next `goto` call.
  No reload needed (`command gotodir` re-execs the script each call).
- **`share/gotodir/gotodir.sh`** — the function is loaded into shell
  memory; reload with `exec zsh` (or `source ~/.zshrc`).

## Isolated smoke tests

All subcommands honour `GOTODIR_STORE` so you can test against a
throwaway file without touching your real bookmarks:

```sh
store=$(mktemp)
GOTODIR_STORE=$store bin/gotodir add foo /tmp
GOTODIR_STORE=$store bin/gotodir list
GOTODIR_STORE=$store bin/gotodir get foo
GOTODIR_STORE=$store bin/gotodir rm  foo
rm "$store"
```

`init` similarly honours `GOTODIR_INIT_RC` (and `GOTODIR_INIT_SHELL`):

```sh
rc=$(mktemp)
GOTODIR_INIT_SHELL=zsh GOTODIR_INIT_RC=$rc bin/gotodir init
cat "$rc"
rm "$rc"
```

## Releasing

`gotodir` is distributed via the Homebrew tap
[`JasGH/homebrew-gotodir`](https://github.com/JasGH/homebrew-gotodir).
A release is five steps: bump the version, push your code, tag the
release, refresh the formula, and verify.

Tags are permanent. Never move or delete a tag that's been published —
if you ship a bad release, fix forward with a new patch version.

### 1. Bump the version

In `bin/gotodir`, change:

```sh
VERSION="0.1.0"
```

to the new version (e.g. `0.1.1`). Add a `CHANGELOG.md` entry that
explains what changed.

### 2. Push code

```sh
cd ~/Projects/gotodir
git add -p && git commit -m "Release vX.Y.Z"
git push
```

### 3. Tag the release

```sh
git tag vX.Y.Z
git push origin vX.Y.Z
```

### 4. Refresh the formula

```sh
curl -sL https://github.com/JasGH/gotodir/archive/refs/tags/vX.Y.Z.tar.gz \
  | shasum -a 256
```

Edit `~/Projects/homebrew-gotodir/Formula/gotodir.rb`:

- Update `url` to point at the new tag.
- Update `version` to match.
- Replace `sha256` with the value from the command above.

Then:

```sh
cd ~/Projects/homebrew-gotodir
git add Formula/gotodir.rb
git commit -m "gotodir X.Y.Z"
git push
```

### 5. Verify

```sh
brew update
brew upgrade gotodir
gotodir version    # → X.Y.Z
```

## Picking version numbers

Follow [semantic versioning](https://semver.org):

- **Patch** (`0.1.0` → `0.1.1`): bug fixes, small tweaks, doc updates.
- **Minor** (`0.1.0` → `0.2.0`): new features or commands that don't
  break existing behaviour.
- **Major** (`0.x` → `1.0`, then `1.x` → `2.x`): breaking changes —
  removed flags, changed storage format, etc.

Until `1.0.0`, minor bumps are allowed to include small breaking
changes — just call them out in the changelog.

## Coding style

- **`bin/gotodir`**: POSIX `sh` — no bashisms. If in doubt, test under
  `dash`.
- **`share/gotodir/gotodir.sh`**: bash/zsh compatible. `local` is fine;
  arrays and `[[ ]]` are not (zsh and bash disagree on edge cases).
- **stdout vs stderr**: resolved paths and other data the wrapper needs
  to capture go to stdout. Everything else (status, errors, prompts)
  goes to stderr. Don't break this — the `goto` function captures
  stdout to call `cd`.
- **Storage format**: `name=/absolute/path`, one per line, in the file
  pointed to by `$GOTODIR_STORE` (default `~/.goto-projects`). Don't
  break this — users hand-edit it.
