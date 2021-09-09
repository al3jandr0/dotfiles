#!/bin/bash
set -e
# todo: add drivers shenanigans 
#### debian out of the box has shitty resolution
# todo: increase windows lock tiemout
# choosing a I forgot its name load env
# MISING:
#   - dmenu

FOREING_TOOL_REPO_DIR="$HOME/foreing-tool-repos/"
PGK_DIR="$HOME/installation-packages/"
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

is_dry_run() {
    if [ -z "$DRY_RUN" ]; then
        return 1
    else
        return 0
    fi
}

user=$(id -un 2>/dev/null || true)
sh_c="sh -c"
if [ "$user" != 'root' ]; then
    if command_exists sudo; then
        shc_c='sudo sh -c'
    elif command_exists su; then
        sh_c='su -c'
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
    sh_c="echo"
fi

$sh_c "apt install sudo bash git vim neovim curl xmonad xmobar"

#### Fonts
NERD_FONTS_DIR="${FOREING_TOOL_REPO_DIR}nerd-fonts"
if [ ! -d $FOREING_TOOL_REPO_DIR ]; then
    $sh_c "mkdir $FOREING_TOOL_REPO_DIR"
fi
if [ ! -d "$NERD_FONTS_DIR" ]; then
    $sh_c "git clone https://github.com/ryanoasis/nerd-fonts.git $NERD_FONTS_DIR"
else
    $sh_c "git -C $NERD_FONTS_DIR pull"
fi

$sh_c "${NERD_FONTS_DIR}install.sh Mononoki" 

#### Alacritty
# Install rust compiler
if [ ! command -v restup &> /dev/null ]; then
    $sh_c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi
$sh_c "rustup override set stable"
$sh_c "rustup update stable"

# install deps
$sh_c "apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3"

#ALACRITTY_DIR="$FOREING_TOOL_REPO_DIR/alacritty"
#if [ ! -d "$ALACRITTY_DIR" ]; then
#    git clone https://github.com/alacritty/alacritty.git $ALACRITTY_DIR
#    cd $ALACRITTY_DIR  #todo: try building from outside the alacrity repo
#    cargo build --release
#
#    sudo cp target/release/alacritty /usr/bin
#    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
#    sudo desktop-file-install extra/linux/Alacritty.desktop
#    sudo update-desktop-database
#    # man page
#    sudo mkdir -p /usr/local/share/man/man1
#    gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
#    cd ..
#fi
## todo: add to dotfiles repo
## mkdir -p ~/.bash_completion
## cp extra/completions/alacritty.bash ~/.bash_completion/alacritty
## echo "source ~/.bash_completion/alacritty" >> ~/.bashrc
#
##### LSD: download from release page
#curl --proto '=https' --tlsv1.2 -sSf https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_amd64.deb -o $PKG_DIR/lsd.deb
#sudo apt install $PGK/lsd.deb
#
##### Starship
## Fetch and install the latest version of starship, if starship is already
## installed it will be updated to the latest version.
#sh -c "$(curl -fsSL https://starship.rs/install.sh)"
#
#
## how about updating apt repo list for non-free libs
## it requires some coordination between foreing keys stored in /uset/share/keyrings/
##    and the repositories in /etc/apt/sources.list.d/ and 
###  todo: update terminal selection to pick a default when allacritty is not available
#
##################
##### DEV      ###
##################
#
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
#sudo tar -xzf $PGK_DIR/jetbrains-toolbox.tar.gz -C /opt
#
#
#
## todo: include firefox non-esr:
#
## Lasttly: setup dotfiles repo
#
## run neo vim 'plugupdate' ?




