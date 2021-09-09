#!/bin/bash
set -e
# todo: add drivers shenanigans 
#### debian out of the box has shitty resolution
# todo: increase windows lock tiemout
# choosing a I forgot its name load env
# MISING:
#   - dmenu

FOREING_TOOL_REPO_DIR="$HOME/foreing-tool-repos/"
PKG_DIR="$HOME/installation-packages/"
INSTALL_SCRIPT_DIR="$HOME/installation-scripts/"
DRY_RUN=${DRY_RUN:-}
for i in "$@"; do
    case $i in
        --dry-run)
            DRY_RUN=1
            echo "dry dry"
            ;;
        --help)
            echo "Setups Debian to Alej's preferences. It requires user to execute commands as root"
            echo "To add user to sudo do"
            echo "> su"
            echo "> /sbin/adduser \$USER sudo"
            echo "> systemctl reboot" # todo: find out whether rebooting is necesary
            echo "OPTIONS:"
            echo "--dry-run     Prints commands without executing them"
            exit 0
            ;;
        *)
            # unknown option
            echo "unknown parameter passed $i"
            exit 1
            ;;
    esac
    shift
done

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

package_installed() {
    dpkg -s "$@" > /dev/null 2>&1
}

is_dry_run() {
    if [ -z "$DRY_RUN" ]; then
        return 1
    else
        return 0
    fi
}

user=$(id -un 2>/dev/null || true)
sush_c="sh -c" # super user shell command
sh_c="sh -c"  # user shell command
if [ "$user" != 'root' ]; then
    if command_exists sudo; then
        sush_c='sudo sh -c'
    elif command_exists su; then
        sush_c='su -c'
    else
        echo "Error: this installer needs the ability to run commands as root." >&2
        echo "Unable to find either "sudo" or "su" available to make this happen." >&2
        #cat >&2 <<-EOF
        #Error: this installer needs the ability to run commands as root.
        #Unable to find either "sudo" or "su" available to make this happen. 
        #EOF
        exit 1
    fi
fi

if is_dry_run; then
    sush_c="echo"
    sh_c="echo"
fi

if [ ! -d "$FOREING_TOOL_REPO_DIR" ]; then
    $sh_c "mkdir $FOREING_TOOL_REPO_DIR"
fi
if [ ! -d "$PKG_DIR" ]; then
    $sh_c "mkdir $PKG_DIR"
fi

$sush_c "apt install sudo bash git vim neovim curl xmonad xmobar suckless-tools"

#### Fonts
NERD_FONTS_DIR="${FOREING_TOOL_REPO_DIR}nerd-fonts/"
if [ ! -d "$NERD_FONTS_DIR" ]; then
    $sush_c "git clone https://github.com/ryanoasis/nerd-fonts.git $NERD_FONTS_DIR"
else
    $sush_c "git -C $NERD_FONTS_DIR pull"
fi

$sush_c "${NERD_FONTS_DIR}install.sh Mononoki" 

#### Alacritty
# Install rust compiler
RUST_BIN_DIR="$HOME/.cargo/bin/"
if ! command_exists restup; then # or rustup bin dir doesnt exists
    $sh_c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y --profile minimal"
fi
#$sh_c ". $HOME/.cargo/env"
$sh_c "${RUST_BIN_DIR}rustup override set stable"
$sh_c "${RUST_BIN_DIR}rustup update stable"
# TODO: add rustup to bashrc

# install deps
$sush_c "apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3"

ALACRITTY_DIR="${FOREING_TOOL_REPO_DIR}alacritty/"
if [ ! -d "$ALACRITTY_DIR" ]; then
    $sh_c "git clone https://github.com/alacritty/alacritty.git $ALACRITTY_DIR"
    #cd $ALACRITTY_DIR  #todo: try building from outside the alacrity repo
    $sh_c "${RUST_BIN_DIR}cargo build --release --manifest-path=${ALACRITTY_DIR}Cargo.toml"

    $sush_c "cp ${ALACRITTY_DIR}target/release/alacritty /usr/bin"
    $sush_c "cp ${ALACRITTY_DIR}extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg"
    $sush_c "desktop-file-install ${ALACRITTY_DIR}extra/linux/Alacritty.desktop"
    $sush_c "update-desktop-database"
    # man page
    $sush_c "mkdir -p /usr/local/share/man/man1"
    $sush_c "gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null"
fi
# todo: add to dotfiles repo
# TODO: add autocomplete  https://github.com/alacritty/alacritty/blob/master/INSTALL.md#install-the-rust-compiler-with-rustup
# mkdir -p ~/.bash_completion
# cp extra/completions/alacritty.bash ~/.bash_completion/alacritty
# echo "source ~/.bash_completion/alacritty" >> ~/.bashrc

##### LSD: download from release page
# curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Peltoche/lsd/releases/latest
## in case you'd like to programatically download the latest version
if package_isntalled lsd; then
    $sh_c "wget https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_amd64.deb -O ${PKG_DIR}lsd.deb"
fi
$sush_c "apt install ${PKG_DIR}lsd.deb"

#### Starship
# Fetch and install the latest version of starship, if starship is already
# installed it will be updated to the latest version.
$sush_c  "curl -fsSL https://starship.rs/install.sh | sudo sh -- -y"

# how about updating apt repo list for non-free libs
# it requires some coordination between foreing keys stored in /uset/share/keyrings/
#    and the repositories in /etc/apt/sources.list.d/ and 
##  todo: update terminal selection to pick a default when allacritty is not available

#################
#### DEV      ###
#################

#sudo apt install nodejs npm python3 pip3
#
##### yarn
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt upgrade
#sudo apt isntall yarn
#
##### python
## alias python3 and pip3 to python and pip
#
##### Docker
# INSTALL_SCRIPT_DIR="$HOME/installation-scripts/"
## if file not here
#curl -fsSL https://get.docker.com -o get-docker.sh
#sudo sh get-docker.sh
#
##### Vscode
## todo: if no command 'code, then get deb
#curl -sS 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -o $PKG_DIR/vscode.deb
#sudo apt install $PKG_DDIR/vscode.deb
#
## jetbrains toolbox app
#curl -sS 'https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-1.21.9712.tar.gz' -o $PKG_DIR/jetbrains-toolbox.tar.gz
#sudo tar -xzf $PKG_DIR/jetbrains-toolbox.tar.gz -C /opt
#
#
#
## todo: include firefox non-esr:
#
## Lasttly: setup dotfiles repo
#
## run neo vim 'plugupdate' ?




