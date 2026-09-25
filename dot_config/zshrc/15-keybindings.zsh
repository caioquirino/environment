# -----------------------------------------------------
# Key bindings — Home/End/Delete, word jumps/kills, completion, editor
# Terminals send different sequences depending on cursor-key mode
# (normal vs application), so bind every common variant.
# -----------------------------------------------------

bindkey -e

for _km in emacs viins vicmd; do
  bindkey -M $_km '^[[H'  beginning-of-line  # Home (normal mode)
  bindkey -M $_km '^[OH'  beginning-of-line  # Home (application mode)
  bindkey -M $_km '^[[1~' beginning-of-line  # Home (vt/tmux)
  bindkey -M $_km '^[[7~' beginning-of-line  # Home (rxvt)
  bindkey -M $_km '^[[F'  end-of-line        # End (normal mode)
  bindkey -M $_km '^[OF'  end-of-line        # End (application mode)
  bindkey -M $_km '^[[4~' end-of-line        # End (vt/tmux)
  bindkey -M $_km '^[[8~' end-of-line        # End (rxvt)
  bindkey -M $_km '^[[3~' delete-char        # Delete
  bindkey -M $_km '^[[1;5D' backward-word    # Ctrl+Left
  bindkey -M $_km '^[[1;5C' forward-word     # Ctrl+Right
  bindkey -M $_km '^[[1;3D' backward-word    # Alt+Left
  bindkey -M $_km '^[[1;3C' forward-word     # Alt+Right
  bindkey -M $_km '^[^[[D'  backward-word    # Alt+Left (rxvt)
  bindkey -M $_km '^[^[[C'  forward-word     # Alt+Right (rxvt)
done
unset _km

# Word deletion — Ctrl+Backspace sends ^H in wezterm/kitty (plain Backspace is ^?)
bindkey -M emacs '^H'      backward-kill-word  # Ctrl+Backspace
bindkey -M viins '^H'      backward-kill-word
bindkey -M emacs '^[[3;5~' kill-word           # Ctrl+Delete
bindkey -M viins '^[[3;5~' kill-word

# Shift+Tab walks the completion menu backwards
bindkey -M emacs '^[[Z' reverse-menu-complete
bindkey -M viins '^[[Z' reverse-menu-complete

# Ctrl+X Ctrl+E — edit the current command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M emacs '^X^E' edit-command-line
bindkey -M vicmd 'v'    edit-command-line
