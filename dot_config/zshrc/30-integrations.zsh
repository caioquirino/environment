# -----------------------------------------------------
# Integrations — shell hooks for the CLI tools
#
# Tool versions (java, maven, gradle, node, jikkou, …) are managed by
# mise; see ~/.config/mise/config.toml. `mise activate` switches them
# per project on cd. Shims in env.sh cover non-interactive shells.
# -----------------------------------------------------

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY HIST_IGNORE_SPACE

# fzf keybindings (Ctrl-R, Ctrl-T, Alt-C)
# fd lists files faster than find and honours .gitignore
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
(( $+commands[fzf] )) && source <(fzf --zsh)

# zoxide — `cd` itself learns: `cd foo` jumps to the best match for
# "foo" when ./foo doesn't exist; `cdi` picks interactively
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd cd)"
fi

# atuin — smarter history search; keeps Ctrl-R.
# Up/Down stay native zsh so a recalled line is immediately editable.
# Ctrl-R is the only search UI. New commands are still written to both stores.
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# direnv — per-project env, no extra action
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# bat as man pager (theme lives in ~/.config/bat/config)
if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# mise — shims in env.sh keep tools on PATH; activate adds per-project
# switching (cd into a project with a mise.toml or .nvmrc and it applies)
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# ---------- kitty shell integration (OSC 7 / CWD) ----------
if [[ -n $KITTY_INSTALLATION_DIR && -r $KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh ]]; then
  source "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh"
fi
