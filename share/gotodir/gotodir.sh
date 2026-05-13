# gotodir — shell wrapper providing the `goto` command.
# Source this file from your ~/.zshrc or ~/.bashrc.
# Requires bash or zsh (uses `local`).

goto() {
  local _gd_launch=0
  if [ "${1:-}" = "-c" ]; then
    _gd_launch=1
    shift
  fi

  case "${1:-}" in
    add|rm|remove|list|ls|version|--version)
      command gotodir "$@"
      return $?
      ;;
    -h|--help|help)
      cat <<'EOF'
goto — quick navigation between project directories.

Usage:
  goto [-c]                Open arrow-key picker, then cd into the choice.
  goto [-c] <name>         cd directly to bookmarked <name>.
  goto add <name> [path]   Bookmark <path> (defaults to current dir) as <name>.
  goto list                List all bookmarks.
  goto rm  <name>          Remove a bookmark.

Flags:
  -c    After cd, run `claude` in the destination directory.
EOF
      return 0
      ;;
    "")
      local _gd_dir
      _gd_dir="$(command gotodir pick)" || return $?
      cd "$_gd_dir" || return 1
      [ "$_gd_launch" -eq 1 ] && claude
      return 0
      ;;
    *)
      local _gd_dir
      _gd_dir="$(command gotodir get "$1")" || return $?
      cd "$_gd_dir" || return 1
      [ "$_gd_launch" -eq 1 ] && claude
      return 0
      ;;
  esac
}
