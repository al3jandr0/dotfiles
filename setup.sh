#!/bin/bash
set -e
# todo: increase windows lock tiemout

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

file_exists() {
    test -f "$@" > /dev/null 2>&1 
}

dir_exists() {
    test -d "$@" > /dev/null 2>&1 
}

is_dry_run() {
    if [ -z "$DRY_RUN" ]; then
        return 1
    else
        return 0
    fi
}

user=$(id -un 2>/dev/null || true)
sush="sh" # super user shell command
sh_c="sh -c"  # user shell command
if [ "$user" != 'root' ]; then
    if command_exists sudo; then
        sush='sudo sh'
    elif command_exists su; then
        sush='su'
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

sush_c="$sush -c"
sush_s="$sush -s"
if is_dry_run; then
    sush_c="echo"
    sush_s="echo"
    sh_c="echo"
fi

if [ ! -d "$FOREING_TOOL_REPO_DIR" ]; then
    $sh_c "mkdir $FOREING_TOOL_REPO_DIR"
fi
if [ ! -d "$PKG_DIR" ]; then
    $sh_c "mkdir $PKG_DIR"
fi

$sush_c "apt -y install sudo bash git vim curl wget ssh suckless-tools brightnessctl brightness-udev"

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
$sh_c "${RUST_BIN_DIR}rustup override set stable"
$sh_c "${RUST_BIN_DIR}rustup update stable"

# install deps
$sush_c "apt -y install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3"

# TODO: allow for updating alacritty
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

#### LSD: download from release page
# curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Peltoche/lsd/releases/latest
## in case you'd like to programatically download the latest version
if ! package_installed lsd; then
    $sh_c "wget https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_amd64.deb -O ${PKG_DIR}lsd.deb"
fi
$sush_c "apt -y install ${PKG_DIR}lsd.deb"

#### Starship
# Fetch and install the latest version of starship, if starship is already
# installed it will be updated to the latest version.
$sush_c  "curl -fsSL https://starship.rs/install.sh | sudo sh -s -- -y"

#################
#### DEV      ###
#################

#### neovim
$sh_c "wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -O ${PKG_DIR}nvim"
$sh_c "install -D -t $HOME/.local/bin/ -m 755 ${$PKG_DIR}nvim"

$sush_c "apt -y install nodejs npm python3"
#### yarn
if ! package_installed yarn; then
    $sush_c "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -"
    $sush_c "echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list"
fi
$sush_c "apt -y update"
$sush_c "apt -y install yarn"

#### python
$sush_c "apt -y install python3 python3-pip"
$sush_c "ln -sf /usr/bin/pip3 /usr/bin/pip" 
$sush_c "ln -sf /usr/bin/python3 /usr/bin/python" 

#### Docker
if ! command_exists docker; then
    $sush_c "curl -fsSL https://get.docker.com | sh"
    # docker needs root permisions. todo: find alternatives
    $sush_c "groupadd -f docker"
    $sush_c "usermod -aG docker $user"
fi

#### Vscode
if ! package_installed code; then
    $sh_c "wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O ${PKG_DIR}vscode.deb"
    $sush_c "apt -y install ${PKG_DIR}vscode.deb"
fi

#### jetbrains toolbox app
#todo: figure out how to get the latest stable version
if ! file_exists "/usr/local/bin/jetbrains-toolbox"; then
    $sh_c "curl -sS 'https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-1.21.9712.tar.gz' -o ${PKG_DIR}jetbrains-toolbox.tar.gz"
    $sh_c "tar -xzf ${PKG_DIR}jetbrains-toolbox.tar.gz -C ${PKG_DIR}"
    $sh_c "rm ${PKG_DIR}jetbrains-toolbox.tar.gz"
    $sush_c "mv ${PKG_DIR}jetbrains-toolbox-* /opt/jetbrains-toolbox"
    $sush_c "chmod 755 /opt/jetbrains-toolbox"
    $sush_c "chmod 755 /opt/jetbrains-toolbox/jetbrains-toolbox"
    $sush_c "ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox"
fi

#### non esr firefox
if ! file_exists "/opt/firefox/firefox"; then
    $sh_c "wget 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US' -O ${PKG_DIR}firefox"
    $sush_c "tar -xjf ${PKG_DIR}firefox -C /opt/"  
    $sush_c "chmod 755 ${PKG_DIR}firefox /opt/firefox"  
    $sush_c "chmod 755 ${PKG_DIR}firefox /opt/firefox/firefox"  
    $sush_c "ln -sf /opt/firefox/firefox /usr/local/bin/firefox"
    $sush_c "update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200 && sudo update-alternatives --set x-www-browser /opt/firefox/firefox"
fi

#### dotfiles
if ! dir_exists "$HOME/.dotfiles-git-config"; then
    $sh_c "git clone --bare https://gitlab.com/ale-j/dotfiles.git $HOME/.dotfiles-git-config"
    #$sh_c "git clone --bare git@gitlab.com:ale-j/dotfiles.git $HOME/.dotfiles-git-config"
    $sh_c "/usr/bin/git --git-dir=$HOME/.dotfiles-git-config/ --work-tree=$HOME checkout --force"
    $sh_c "/usr/bin/git --git-dir=$HOME/.dotfiles-git-config/ --work-tree=$HOME config --local status.showUntrackedFiles no"
fi

#######################################################
####    Scripts below depend on dotfiles existing
#######################################################

#### Xmonad v16.99 & xmobar v0.19 ?
# xmonad has a dependcy with dotfiles. it requiores xmonad.hs  you could create a dummy xmonad.sh
XMONAD_DIR="$HOME/.xmonad/"
#$sush_c "apt -y install haskell-platform" 

# sources are needed for xmonad version newer than 0.15
if ! dir_exists "$XMONAD_DIR/xmonad"; then
    $sh_c "git clone https://github.com/xmonad/xmonad $XMONAD_DIR/xmonad" 
    $sh_c "git clone https://github.com/xmonad/xmonad-contrib $XMONAD_DIR/xmonad-contrib" 
    #$sh_c "git -C $XMONAD_DIR/xmonad checkout 33a86c0cdb9aa481e23cc5527a997adef5e32d42"
    #$sh_c "git -C $XMONAD_DIR/xmonad-contrib checkout 0c6fdf4e75dd4d31bc8423010fbabbab7c23ee03"
else
    # pulls latest. consider anchoring to the commmits above
    $sh_c "git -C ${XMONAD_DIR}xmonad pull"
    $sh_c "git -C ${XMONAD_DIR}xmonad-contrib pull"
fi

$sush_c "apt -y install haskell-stack"
$sh_c "stack upgrade"

# installing  xmonad from source using stacks yields a newer version 16.999
if ! file_exists "$HOME/.local/bin/xmonad"; then
    $sush_c "apt -y install libx11-dev libxft-dev libxinerama-dev libxrandr-dev libxss-dev libxss-dev"
    $sh_c "cd $XMONAD_DIR && $HOME/.local/bin/stack init"
    $sh_c "cd $XMONAD_DIR && $HOME/.local/bin/stack install"
    $sh_c "cd $HOME"
fi

# xmonad installation with cabal yiels v15 
#if ! file_exists "$HOME/.cabal/bin/xmonad"; then
#    $sush_c "apt -y install libx11-dev libxft-dev libxinerama-dev libxrandr-dev libxss-dev libxss-dev"
#    $sh_c "cabal update"
#    $sh_c "cabal install --package-env=${XMONAD_DIR}xmonad --lib xmonad xmonad-contrib"
#    $sh_c "cabal install --overwrite-policy=always --package-env=${XMONAD_DIR}xmonad xmonad"
#fi

# commented out is installation of xmobar usign stack
#if ! file_exists "$HOME/.local/bin/xmobar"; then
#     $sush_c "apt -y install libghc-alsa-core-dev libxpm-dev"
#    if [ ! -d "${FOREING_TOOL_REPO_DIR}xmobar" ]; then
#        $sh_c "git clone https://github.com/jaor/xmobar.git ${FOREING_TOOL_REPO_DIR}xmobar"
#    else
#        $sh_c "git -C $NERD_FONTS_DIR pull"
#    fi
#    #TODO: checkout a label
#    $sh_c "git -C ${FOREING_TOOL_REPO_DIR}xmobar checkout b8bcc61a632f49533ff476b3483cb7299866d5dc"
#    $sh_c "cd ${FOREING_TOOL_REPO_DIR}xmobar && stack install --flag xmobar:all_extensions"
#    $sh_c "cd $HOME"
#fi

if ! file_exists "/usr/share/xsessions/xmonad.desktop"; then
    sush_c "cat >/usr/share/xsessions/xmonad.desktop <<-EOF
    [Desktop Entry]
    Encoding=UTF-8
    Name=XMonad
    Comment=Lightweight tiling window manager
    Exec=xmonad
    Icon=xmonad.png
    Type=XSession
EOF"
fi
$sush_c "ln -sf $HOME/.local/bin/xmonad /usr/local/bin/xmonad"

# Install cabal
#if ! command_exists cabal; then
if ! file_exists "opt/cabal"; then
    $sh_c "curl -sS 'https://downloads.haskell.org/~cabal/cabal-install-3.6.0.0/cabal-install-3.6.0.0-x86_64-linux.tar.xz' | tar -xJ -C $PKG_DIR"
    $sush_c "mv ${PKG_DIR}cabal /opt/"
    $sush_c "ln -sf /opt/cabal /usr/local/bin/cabal"
fi
# xmobar deps
if ! file_exists "$HOME/.cabal/bin/xmobar"; then
    $sush_c "apt -y install libghc-alsa-core-dev libxpm-dev"
    #customize the extensions to remove those not needed :S
    $sh_c "cabal update"
    $sh_c "cabal install xmobar --flags='all_extensions'"
fi
$sush_c "lb -sf $HOME/.cabal/bin/xmobar /usr/local/bin/xmobar"

#### neo vim 'plugupdate' 
$sh_c "curl -fLo ${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
$sh_c "nvim +PlugInstall +qa"

# Sets dpi 
dim=$(xdpyinfo | grep -oP 'dimensions:\s+\K\S+')
case $dim in
    1920x1080)
        echo "Xft.dpi: 96" > $HOME/.Xresources
        ;;
    # 4K
    3840x2160)
        echo "Xft.dpi: 144" > $HOME/.Xresources
        ;;
esac

#### Lutris - games on linux
if ! package_isntalled lutris; then
    $sush_c "curl -sS https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key | apt-key add -"
    $sush_c "echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./' | tee /etc/apt/sources.list.d/lutris.list"
fi
$sush_c "apt -y update"
$sush_c "apt -y install lutris"

#### cleanup:
$sush_c "apt update"
$sush_c "apt -y upgrade"
$sush_c "apt -y autoremove"

#### Additional manual steps
# Generare ssh keys
cat >&2 <<-EOF
Generate ssh key:   
> ssh-keygen -t ed25519
Copy to clipboard:
> xclip -sel clip < ~/.ssh/id_ed25519.pub
EOF



