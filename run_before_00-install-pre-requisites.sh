#!/bin/sh
set -e

(export $(cat /etc/os-release | grep ^ID=))|| true

# if WSL2 is detected, set variable IS_WSL2 to true
if uname -r | grep -q "WSL2"; then
    IS_WSL2=true
else
    IS_WSL2=false
fi

function install_pre_requisites_linux() {
    if [ "$ID" = "arch" ]; then

        # skip if yay is already in $PATH
        type yay >/dev/null 2>&1 || {
            # install yay unattended
            sudo pacman -S --needed git base-devel
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si --noconfirm
            cd ..
            rm -rf yay
        }


        # skip if op is already in $PATH
        type op >/dev/null 2>&1 || {
            echo "I nstalling 1password-cli - wsl=$IS_WSL2"
            if [ "$IS_WSL2" = true ]; then
                OP_PATH=$(find /mnt/c/Users/caioq/AppData/Local/Microsoft/WinGet/Packages/ -name "op.exe")
                sudo ln -s $OP_PATH /usr/bin/op
            else
                yay -S 1password-cli --noconfirm
            fi
        }
    fi
}


function install_pre_requisites_macos() {

    # skip if brew is already installed
    type brew >/dev/null 2>&1 || {
        # install brew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }

    # skip if op is already in $PATH
    type op >/dev/null 2>&1 || {
        # install 1password cli unattended
        brew install 1password
    }
}

case "$(uname -s)" in
Darwin)
    # commands to install password-manager-binary on Darwin
    install_pre_requisites_macos
    ;;
Linux)
    # commands to install password-manager-binary on Linux
    install_pre_requisites_linux
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac