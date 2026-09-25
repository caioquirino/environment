#!/bin/sh
# Bootstraps what chezmoi needs before it can render templates: yay on Arch
# and the 1Password CLI (`op`). Runs as a read-source-state.pre hook (see
# .chezmoi.toml.tmpl), so it runs on every chezmoi command and must stay
# fast and quiet once everything is installed.
set -e

ID=""
[ -r /etc/os-release ] && ID=$(. /etc/os-release && echo "$ID")

# if WSL2 is detected, set variable IS_WSL2 to true
if uname -r | grep -q "WSL2"; then
    IS_WSL2=true
else
    IS_WSL2=false
fi

install_pre_requisites_linux() {
    if [ "$ID" = "arch" ]; then

        # skip if yay is already in $PATH
        type yay >/dev/null 2>&1 || {
            # install yay unattended
            sudo pacman -S --needed --noconfirm git base-devel
            yay_build=$(mktemp -d)
            git clone https://aur.archlinux.org/yay.git "$yay_build/yay"
            (cd "$yay_build/yay" && makepkg -si --noconfirm)
            rm -rf "$yay_build"
        }


        # On WSL2, install a resilient wrapper to invoke Windows op.exe
        if [ "$IS_WSL2" = true ]; then
            if [ ! -f /usr/local/bin/op ]; then
                echo "Installing resilient 1Password CLI wrapper in /usr/local/bin/op"
                sudo tee /usr/local/bin/op >/dev/null << 'WRAPPER_EOF'
#!/bin/sh
if command -v op.exe >/dev/null 2>&1; then
    exec op.exe "$@"
fi

WIN_LOCALAPPDATA=""
if command -v powershell.exe >/dev/null 2>&1; then
    WIN_LOCALAPPDATA="$(wslpath "$(powershell.exe -NoProfile -Command '$env:LOCALAPPDATA' 2>/dev/null | tr -d '\r')" 2>/dev/null)"
elif command -v cmd.exe >/dev/null 2>&1; then
    WIN_LOCALAPPDATA="$(wslpath "$(cmd.exe /c "echo %LOCALAPPDATA%" 2>/dev/null | tr -d '\r')" 2>/dev/null)"
fi

if [ -n "$WIN_LOCALAPPDATA" ]; then
    if [ -x "$WIN_LOCALAPPDATA/Microsoft/WinGet/Links/op.exe" ]; then
        exec "$WIN_LOCALAPPDATA/Microsoft/WinGet/Links/op.exe" "$@"
    fi
    OP_PKG="$(find "$WIN_LOCALAPPDATA/Microsoft/WinGet/Packages" -maxdepth 3 -name "op.exe" 2>/dev/null | head -n 1)"
    if [ -n "$OP_PKG" ] && [ -x "$OP_PKG" ]; then
        exec "$OP_PKG" "$@"
    fi
fi

for cand in \
    "/mnt/c/Program Files/1Password/app/8/op.exe" \
    "/mnt/c/Program Files/1Password/op.exe" \
    "/mnt/c/Program Files (x86)/1Password/op.exe"
do
    if [ -x "$cand" ]; then
        exec "$cand" "$@"
    fi
done

echo "Error: op.exe not found on Windows host" >&2
exit 1
WRAPPER_EOF
                sudo chmod +x /usr/local/bin/op
            fi
        else
            type op >/dev/null 2>&1 || yay -S 1password-cli --noconfirm
        fi
    fi
}


install_pre_requisites_macos() {

    # skip if brew is already installed
    type brew >/dev/null 2>&1 || {
        # install brew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # put the fresh brew on PATH for the rest of this script
        for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            [ -x "$b" ] && eval "$("$b" shellenv)" && break
        done
    }

    # skip if op is already in $PATH
    type op >/dev/null 2>&1 || {
        # install 1password cli unattended
        brew install --cask 1password-cli
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