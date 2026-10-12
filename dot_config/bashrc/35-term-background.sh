# Terminal background — export TERM_BACKGROUND=dark|light for the oh-my-posh
# palette. Asks the terminal once at startup (OSC 11); zsh re-checks per prompt.
if [ -t 0 ] && [ -t 1 ]; then
  _tb_saved=$(stty -g 2>/dev/null) && {
    stty -echo -icanon min 1 time 0
    printf '\033]11;?\a'
    IFS= read -r -t 0.2 -d $'\a' _tb_answer
    stty "$_tb_saved"
    if [[ $_tb_answer =~ rgb:([[:xdigit:]]{2})[[:xdigit:]]*/([[:xdigit:]]{2})[[:xdigit:]]*/([[:xdigit:]]{2}) ]]; then
      if (( (299 * 16#${BASH_REMATCH[1]} + 587 * 16#${BASH_REMATCH[2]} + 114 * 16#${BASH_REMATCH[3]}) / 1000 < 128 )); then
        export TERM_BACKGROUND=dark
      else
        export TERM_BACKGROUND=light
      fi
    fi
  }
  unset _tb_saved _tb_answer
fi
