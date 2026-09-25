# -----------------------------------------------------
# Integrations — transparent, deferred where it matters
#
# Cheap hooks (direnv/zoxide/atuin/fzf/mise shims) run now.
# nvm / SDKMAN / pyenv stay as functions until first use, then
# load themselves in-place so `nvm use`, `sdk install`, `pyenv`
# keep working with no extra typing.
#
# Completions are native zsh and only read on-disk state, so Tab
# works before the real tool is sourced. sched +1 loads the real
# functions a moment after the first prompt while idle.
# -----------------------------------------------------

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY HIST_IGNORE_SPACE

# fzf keybindings (Ctrl-R, Ctrl-T, Alt-C)
# fd lists files faster than find and honours .gitignore
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
(( $+commands[fzf] )) && source <(fzf --zsh)

# zoxide — `cd` that learns; `zi` to fuzzy-jump
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# atuin — smarter history search; keeps Ctrl-R.
# Up/Down stay native zsh so a recalled line is immediately editable.
# Ctrl-R is the only search UI. New commands are still written to both stores.
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# direnv — per-project env, no extra action
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# bat as man pager
if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export BAT_THEME="${BAT_THEME:-ansi}"
fi

# mise — already on PATH via shims in 00-init; activate for hooks
# (cd into a project with a .mise.toml and tools appear)
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

_zsh_compdef() {
  (( $+functions[compdef] )) && compdef "$@"
}

# ---------- deferred: nvm ----------
# node/npm stay on PATH from 00-init. nvm.sh (~250ms) is not sourced at
# startup. Completions come from a native zsh completer that only reads
# ~/.nvm (no nvm.sh).
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

_zsh_nvm_loaded=0
_zsh_load_nvm() {
  (( _zsh_nvm_loaded )) && return
  _zsh_nvm_loaded=1
  unset -f nvm
  if [[ -s /usr/share/nvm/nvm.sh ]]; then
    source /usr/share/nvm/nvm.sh
  elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
  elif [[ -n ${NVM_SCRIPT:-} && -s $NVM_SCRIPT ]]; then
    source "$NVM_SCRIPT"
  fi
  _zsh_compdef _nvm nvm
}

nvm() { _zsh_load_nvm; nvm "$@"; }

_nvm() {
  local -a commands aliases versions
  commands=(
    'help:Show help'
    'install:Download and install a version'
    'uninstall:Uninstall a version'
    'use:Modify PATH to use a version'
    'run:Run command with a version'
    'exec:Run command on a PATH with a version'
    'alias:Set or show aliases'
    'unalias:Remove an alias'
    'reinstall-packages:Reinstall global npm packages'
    'current:Display active version'
    'list:List installed versions'
    'ls:List installed versions'
    'list-remote:List remote versions'
    'ls-remote:List remote versions'
    'install-latest-npm:Install latest npm'
    'cache:Manage cache'
    'deactivate:Undo nvm PATH changes'
    'unload:Unload nvm'
    'version:Show version'
    'version-remote:Show remote version'
    'which:Show path to node'
  )
  versions=(${NVM_DIR}/versions/node/v*(N:t))
  versions=(${versions#v})
  aliases=(${NVM_DIR}/alias/^lts(N:t) ${NVM_DIR}/alias/lts/*(N:t2))
  aliases+=(node stable unstable default system)

  local state
  _arguments -C \
    '1:nvm command:->cmd' \
    '*:: :->args'
  case $state in
    cmd) _describe -t commands 'nvm command' commands ;;
    args)
      case ${words[1]} in
        use|run|exec|uninstall|which|reinstall-packages)
          _describe -t versions 'node version' versions
          _describe -t aliases 'alias' aliases
          ;;
        ls|list|alias|unalias|install|ls-remote|list-remote|version-remote)
          _describe -t aliases 'alias' aliases
          ;;
      esac
      ;;
  esac
}
_zsh_compdef _nvm nvm

# ---------- deferred: SDKMAN ----------
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

_zsh_sdk_loaded=0
_zsh_load_sdkman() {
  (( _zsh_sdk_loaded )) && return
  _zsh_sdk_loaded=1
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  _zsh_compdef _sdk sdk
}

sdk() { _zsh_load_sdkman; sdk "$@"; }

_sdk() {
  local -a subcommands candidates versions
  subcommands=(
    'help:Show help'
    'install:Install a candidate version'
    'uninstall:Uninstall a candidate version'
    'list:List candidates or versions'
    'use:Use a candidate version in this shell'
    'config:Edit SDKMAN config'
    'default:Set the default version'
    'home:Show install path'
    'env:Manage .sdkmanrc'
    'current:Show current version'
    'upgrade:Upgrade a candidate'
    'version:Show SDKMAN version'
    'offline:Enable or disable offline mode'
    'selfupdate:Update SDKMAN'
    'update:Refresh candidate metadata'
    'flush:Flush caches'
  )
  if [[ -r $SDKMAN_DIR/var/candidates ]]; then
    candidates=(${(s:,:)$(<"$SDKMAN_DIR/var/candidates")})
  else
    candidates=(${SDKMAN_DIR}/candidates/*(N:t))
  fi

  local state
  _arguments -C \
    '1:sdk subcommand:->cmd' \
    '*:: :->args'
  case $state in
    cmd) _describe -t commands 'sdk command' subcommands ;;
    args)
      case ${words[1]} in
        help)
          _describe -t commands 'sdk command' subcommands
          ;;
        install|uninstall|list|use|default|home|current|upgrade)
          if (( CURRENT == 1 )); then
            _describe -t candidates 'candidate' candidates
          elif (( CURRENT == 2 )); then
            versions=(${SDKMAN_DIR}/candidates/${words[2]}/^current(N:t))
            _describe -t versions 'version' versions
          fi
          ;;
        env)
          _describe -t envcmds 'env' \
            ('init:Create .sdkmanrc' 'install:Install from .sdkmanrc' 'clear:Clear env')
          ;;
        offline)
          _describe -t modes 'mode' ('enable:offline on' 'disable:offline off')
          ;;
        flush)
          _describe -t caches 'cache' ('tmp:temp' 'metadata:metadata' 'version:version')
          ;;
      esac
      ;;
  esac
}
_zsh_compdef _sdk sdk

# ---------- deferred: pyenv ----------
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

_zsh_pyenv_loaded=0
_zsh_load_pyenv() {
  (( _zsh_pyenv_loaded )) && return
  _zsh_pyenv_loaded=1
  unset -f pyenv
  [[ -d $PYENV_ROOT/bin ]] && path=("$PYENV_ROOT/bin" $path)
  if (( $+commands[pyenv] )); then
    eval "$(pyenv init - zsh)"
  fi
  _zsh_compdef _pyenv pyenv
}

pyenv() { _zsh_load_pyenv; pyenv "$@"; }

_pyenv() {
  local -a commands versions
  commands=(
    'commands:List all available pyenv commands'
    'local:Set or show the local application-specific Python version'
    'global:Set or show the global Python version'
    'shell:Set or show the shell-specific Python version'
    'install:Install a Python version'
    'uninstall:Uninstall a specific Python version'
    'rehash:Rehash pyenv shims'
    'version:Show the current Python version'
    'versions:List all Python versions available to pyenv'
    'which:Display the full path to an executable'
    'whence:List all Python versions that contain the given executable'
    'prefix:Display prefixes for Python versions'
    'root:Display the root directory'
    'shims:List existing pyenv shims'
    'hooks:List hook scripts'
    'exec:Run an executable with the selected Python version'
    'init:Configure the shell environment for pyenv'
    'latest:Print the latest installed or known version'
    '--version:Show pyenv version'
    'help:Show help'
  )
  versions=(${PYENV_ROOT}/versions/*(N:t) system)

  local state
  _arguments -C \
    '1:pyenv command:->cmd' \
    '*:: :->args'
  case $state in
    cmd) _describe -t commands 'pyenv command' commands ;;
    args)
      case ${words[1]} in
        local|global|shell|uninstall|prefix|which)
          _describe -t versions 'python version' versions
          ;;
        help)
          _describe -t commands 'pyenv command' commands
          ;;
      esac
      ;;
  esac
}
_zsh_compdef _pyenv pyenv

# Load the real tools shortly after the first prompt, while idle.
if zmodload zsh/sched 2>/dev/null; then
  sched +1 _zsh_load_nvm
  sched +1 _zsh_load_sdkman
  sched +1 _zsh_load_pyenv
fi

# ---------- kitty shell integration (OSC 7 / CWD) ----------
if [[ -n $KITTY_INSTALLATION_DIR && -r $KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh ]]; then
  source "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh"
fi
