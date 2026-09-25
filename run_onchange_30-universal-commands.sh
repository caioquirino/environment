#!/bin/bash
set -e

# Language runtimes (java, maven, gradle, node, jikkou) are installed by
# mise in run_onchange_after_35-mise-install.sh.tmpl.

if [ "$(getent passwd "$(whoami)" | cut -d: -f7)" != "$(which zsh)" ]; then
  sudo chsh -s "$(which zsh)" "$(whoami)"
fi

sudo pipx ensurepath --global

pipx install poetry
pipx install pre-commit
