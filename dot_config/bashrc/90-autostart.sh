# Fastfetch only on the first terminal, not every split.
if [ -n "$PS1" ] && [ -t 1 ] && command -v fastfetch >/dev/null 2>&1; then
  case "$(tty 2>/dev/null)" in
    *pts*)
      if [ -z "${KITTY_WINDOW_ID:-}" ] || [ "$KITTY_WINDOW_ID" = 1 ]; then
        fastfetch
      fi
      ;;
  esac
fi
