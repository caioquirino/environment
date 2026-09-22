killport() {
  # Check if a port number was provided
  if [[ -z "$1" ]]; then
    echo "❌ Usage: killport <port> [signal]"
    echo "Provide the port number as the first argument."
    return 1
  fi

  local port=$1
  # Strip a potential leading '-' from the signal argument, and default to 'TERM'.
  # This makes 'killport 8080 -9' and 'killport 8080 9' behave identically.
  local signal=${${2#\-}:-TERM}

  # Find the PID using lsof. The '-t' flag returns only the PID.
  local pid=$(lsof -t -i :$port 2>/dev/null)

  # Check if a PID was actually found
  if [[ -z "$pid" ]]; then
    echo "✅ No process found listening on port $port."
    return 0
  else
    echo "Killing process with PID $pid on port $port using signal $signal..."
    # Always prepend the hyphen here, since we stripped it from the input.
    kill "-$signal" "$pid"
    if [[ $? -eq 0 ]]; then
        echo "👍 Successfully sent signal $signal to process $pid."
    else
        echo "⚠️  Failed to kill process $pid. You might need to use sudo."
    fi
  fi
}
