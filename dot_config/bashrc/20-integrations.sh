# Bash hooks for the same tools zsh loads. Skipped when a tool is absent.

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash --disable-up-arrow)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export BAT_THEME="${BAT_THEME:-ansi}"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

if [ -n "${KITTY_INSTALLATION_DIR:-}" ] && [ -r "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash" ]; then
  . "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi
