# -----------------------------------------------------
# Autostart — fastfetch only on the first OS window, not every split
# -----------------------------------------------------

if [[ -o interactive ]] && [[ $(tty) == *"pts"* ]] && (( $+commands[fastfetch] )); then
  # Skip extra splits/tabs: first kitty window id is 1, first wezterm pane id
  # is 0. Other terminals set neither and still show it.
  if [[ ${KITTY_WINDOW_ID:-1} == 1 && ${WEZTERM_PANE:-0} == 0 ]]; then
    fastfetch
  fi
fi
