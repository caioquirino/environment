# -----------------------------------------------------
# Terminal background — export TERM_BACKGROUND=dark|light
# Asks the terminal for its background colour (OSC 11) before every prompt, so
# the oh-my-posh palette follows the theme even when it changes mid-session.
# Works over SSH. Turns itself off if the terminal does not answer.
# -----------------------------------------------------

zmodload zsh/zselect 2>/dev/null

_term_background_detect() {
  emulate -L zsh
  setopt extendedglob
  [[ -z $_term_background_off && -t 0 && -t 1 ]] || return
  # A full line of typeahead is waiting: leave it alone, keep the last answer.
  zselect -t 0 -r 0 2>/dev/null && return

  local saved answer ch
  saved=$(stty -g 2>/dev/null) || return
  # Raw and silent before asking, so the reply is never echoed to the screen.
  stty -echo -icanon min 1 time 0
  print -n '\e]11;?\a'
  # zsh's read -t only bounds the wait for the first byte, so stop on BEL or
  # ST (kitty answers with ST) ourselves instead of using -d.
  answer=
  while IFS= read -r -k 1 -t 0.2 ch; do
    answer+=$ch
    [[ $ch == $'\a' || $answer == *$'\e\\' ]] && break
  done
  stty $saved

  if [[ $answer == (#b)(*)$'\e]11;rgb:'([[:xdigit:]](#c2))[[:xdigit:]]#/([[:xdigit:]](#c2))[[:xdigit:]]#/([[:xdigit:]](#c2))* ]]; then
    # Keys typed before the reply arrived go back into the next command line.
    [[ -n $match[1] ]] && print -z -- $match[1]
    local -i luma=$(( (299 * 16#$match[2] + 587 * 16#$match[3] + 114 * 16#$match[4]) / 1000 ))
    (( luma < 128 )) && export TERM_BACKGROUND=dark || export TERM_BACKGROUND=light
  else
    [[ -n $answer ]] && print -z -- $answer
    _term_background_off=1
  fi
}

_term_background_detect
autoload -Uz add-zsh-hook
add-zsh-hook precmd _term_background_detect
