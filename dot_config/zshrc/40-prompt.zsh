# -----------------------------------------------------
# Prompt — oh-my-posh zen
# -----------------------------------------------------

if (( $+commands[oh-my-posh] )); then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
fi
