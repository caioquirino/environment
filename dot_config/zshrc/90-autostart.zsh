# -----------------------------------------------------
# Autostart — fastfetch only on the first OS window, not every split
# -----------------------------------------------------

if [[ -o interactive ]] && [[ $(tty) == *"pts"* ]] && (( $+commands[fastfetch] )); then
  # Skip extra kitty splits/tabs; first window id is 1, non-kitty still shows it
  if [[ -z ${KITTY_WINDOW_ID:-} || ${KITTY_WINDOW_ID} == 1 ]]; then
    fastfetch
  fi
fi
