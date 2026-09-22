# -----------------------------------------------------
# oh-my-zsh — keep OMZ, drop the duplicate highlighter
# fast-syntax-highlighting is the more capable of the two
# -----------------------------------------------------

ZSH_THEME=""  # prompt is oh-my-posh, not an OMZ theme

plugins=(
  git
  sudo
  web-search
  archlinux
  zsh-autosuggestions
  fast-syntax-highlighting
  copyfile
  copybuffer
  dirhistory
  mise
  colored-man-pages
  1password
)

[[ -r $ZSH/oh-my-zsh.sh ]] && source "$ZSH/oh-my-zsh.sh"
