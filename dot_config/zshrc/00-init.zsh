# -----------------------------------------------------
# INIT — zsh-only setup. Env and PATH live in shell/env.sh
# Tool versions (java, node, …) come from mise, activated in 30-integrations.zsh
# -----------------------------------------------------

# Env, PATH, and tool homes shared with bash.
[[ -r $HOME/.config/shell/env.sh ]] && source "$HOME/.config/shell/env.sh"
typeset -gU path PATH

[[ -r $HOME/.zsh/utils.zsh ]] && source "$HOME/.zsh/utils.zsh"
