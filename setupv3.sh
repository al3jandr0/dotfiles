#!/bin/bash
set -e
set -x

###################################################################################################
##  XDG.                                                                     ##
##---------------------------------------------------------------------------##
##  Directory reference guide:                                               ##
##  https://wiki.archlinux.org/title/XDG_Base_Directory                      ##
###############################################################################
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/config}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
XDG_BIN_HOME=${XDG_BIN_HOME:-$HOME/.local/bin}

# TODO. Rename to shorter names
FOREING_TOOL_REPO_DIR="$XDG_CACHE_HOME/foreing-tool-repos"
FOREING_INSTALL_SCRIPTS_DIR="$XDG_CACHE_HOME/install-scripts"
PKG_DIR="$XDG_CACHE_HOME/installation-packages/"

# Loads OS informational vars
[ -f /etc/os-release ] && . /etc/os-release

is_debian() {
  test -n "$ID" && test "$ID" == "debian"
}

is_ubuntu() {
  test -n "$ID" && test "$ID" == "ubuntu"
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

package_installed() {
  dpkg -s "$@" >/dev/null 2>&1
}

file_exists() {
  test -f "$@" >/dev/null 2>&1
}

dir_exists() {
  test -d "$@" >/dev/null 2>&1
}

user=$(id -un 2>/dev/null || true)
sush="sh"    # super user shell command
sh_c="sh -c" # user shell command
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

if [ ! -d "$FOREING_TOOL_REPO_DIR" ]; then
  $sh_c "mkdir $FOREING_TOOL_REPO_DIR"
fi
if [ ! -d "$PKG_DIR" ]; then
  $sh_c "mkdir $PKG_DIR"
fi

# More recent version than what's available via ubuntu packages
install_wayland_protocols() {
  echo "INTALLING wayland protocols"
  cd $FOREING_TOOL_REPO_DIR
  # TODO: download release
  cd "wayland-protocols-1.44"
  mkdir -p build &&
    cd build &&
    meson setup --prefix=/usr --buildtype=release &&
    ninja
  sudo ninja install
  cd $HOME
}

install_hyprland_from_source() {
  # dependencies from the wiki
  sudo apt install -y build-essential cmake cmake-extras ninja-build meson wget gettext gettext-base fontconfig libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libegl-dev libgles2 libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev libxcb-xinput-dev libtomlplusplus3 libre2-dev

  # to try install other recommended packages that are not available in the distro. I will build from source anyways
  # It didnt work. delete
  #sudo apt install -y hyprland

  sudo apt install -y xdg-desktop-portal-hyprland
  # undocumented deps
  sudo apt install -y hyprwayland-scanner
  # delete these
  #sudo apt install -y libhyprlang-dev libhyprlang2
  sudo apt install -y libhyprcursor-dev libhyprcursor0
  # prolly dont need this?
  sudo apt install -y librust-wayland-client-dev
  sudo apt install -y hyprland-protocols
  # wayland-protocols are too old to build dfrom source
  #sudo apt install -y wayland-protocols
  sudo apt install -y libgbm-dev
  sudo apt install -y libdisplay-info-dev
  sudo apt install -y libpango1.0-dev libxcursor-dev
  sudo apt install -y libxcb-errors-dev
  sudo apt install -y libtomlplusplus-dev

  echo "INTALLING hyprutils"
  cd $FOREING_TOOL_REPO_DIR
  if ! dir_exists hyprutils; then
    git clone --recursive https://github.com/hyprwm/hyprutils
  fi
  cd hyprutils
  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
  cmake --build ./build --config Release --target all -j$(nproc 2>/dev/null || getconf NPROCESSORS_CONF)
  sudo cmake --install build
  cd $HOME

  echo "INTALLING aquamarine"
  cd $FOREING_TOOL_REPO_DIR
  if ! dir_exists aquamarine; then
    git clone --recursive https://github.com/hyprwm/aquamarine
  fi
  cd aquamarine
  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
  cmake --build ./build --config Release --target all -j$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)
  sudo cmake --install build
  cd $HOME

  echo "INTALLING hyprgraphics"
  cd $FOREING_TOOL_REPO_DIR
  if ! dir_exists hyprgraphics; then
    git clone --recursive https://github.com/hyprwm/hyprgraphics
  fi
  cd hyprgraphics
  sudo apt install -y libcairo2-dev libxt-dev libjpeg-dev libwebp-dev libjpeg-dev libmagic-dev libspng-dev
  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
  cmake --build ./build --config Release --target all -j$(nproc 2>/dev/null || getconf NPROCESSORS_CONF)
  sudo cmake --install build
  cd $HOME

  # hyperlang
  echo "INTALLING hyprlang"
  cd $FOREING_TOOL_REPO_DIR
  if ! dir_exists hyprlang; then
    git clone --recursive https://github.com/hyprwm/hyprlang
  fi
  cd hyprlang
  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
  cmake --build ./build --config Release --target hyprlang -j$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)
  sudo cmake --install ./build
  cd $HOME

  # hyprland runtime dependency
  sudo apt install -y qt6-wayland-dev qt6-wayland-private-dev
  sudo apt install -y libqt6qml6 libqt6quick6
  sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-declarative-private-dev
  sudo apt install -y qml6-module-*
  sudo apt install -y libqt6waylandclient6 qml6-module-qtwayland-client-texturesharing libkwaylandclient6 qml6-module-qtwayland-compositor

  echo "INTALLING hyprland qt support"
  cd $FOREING_TOOL_REPO_DIR
  if ! dir_exists hyprland-qt-support; then
    git clone --recursive https://github.com/hyprwm/hyprland-qt-support
  fi
  cd hyprland-qt-support
  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -DINSTALL_QML_PREFIX=/lib/qt6/qml -S . -B ./build
  cmake --build ./build --config Release --target all -j$(nproc 2>/dev/null || getconf NPROCESSORS_CONF)
  sudo cmake --install build
  cd $HOME

  echo "INTALLING hyprland qt utils"
  cd $FOREING_TOOL_REPO_DIR
  if ! dir_exists hyprland-qtutils; then
    git clone --recursive https://github.com/hyprwm/hyprland-qtutils
  fi
  cd hyprland-qtutils
  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -DINSTALL_QML_PREFIX=/lib/qt6/qml -DQT_DEBUG_FIND_PACKAGE=ON -S . -B ./build
  cmake --build ./build --config Release --target all -j$(nproc 2>/dev/null || getconf NPROCESSORS_CONF)
  sudo cmake --install build
  cd $HOME

  # Hyprland
  #if ! command_exists hyprland; then
  cd $FOREING_TOOL_REPO_DIR
  if ! dir_exists Hyprland; then
    git clone --recursive https://github.com/hyprwm/Hyprland
  fi
  cd Hyprland
  make all && sudo make install
  cd $HOME
  #fi
  sudo apt install -y nvidia-utils libnvidia-egl-wayland1
}

##########################
# TODO:
# - [x] Move hyprland instalaton to another file? elsewhere or to a function. and make it idempotent
# - [x] Add nvidia library installations to their own unit or at least group them togeter
# - [x] Install font
# - [x] Move your apps to the end
# - [x] Install McFly
# - [x] Install waybar
#
# - [ ] Install optional prgrams:
# - [x] 1. python(s).
# - [x] 2. nvm/node/npm.
# - [x] 3. sdkman. (no java yet).
# - [x] 4. Docker
# - [x] o. [dont install Lutris since it is only for FFXIV]
# - [x] Asus laptop drivers. asys-linux.org has 2 repos one to control the descretegp, and another one for periferals such as fan curve and keyboard rgb leds. They require patching the linux kernerl and I dont want to get into that. Give it a shot to this project after 1) You got everything else sinstalled and 25.10 has come out.
#
# - [ ] Download dot files
# - - [x] ensure .bashrc is up to date with latest debian and ubuntu
# - - [x] how? github without ssh or https? -- cloning a public repo with https doenst need credentials
# -       1. clone to a temporary folder
#         2. copy files over to their intended location aka HOME
#         3. configure the git repo to track master etc etc
#     [x] compare ubuntu's bash rc and your own. they are different. make sure your's will work with ubuntu and debian
#
# - [x] Install Lazy vim <- this.
# - [ ] 6. vscode (can you programatically install plugins?). Yes but just install snap for now
#
# TODO:
# - [x] NVIM. add mode and line and column numbers
# - [ ] 4 spaces as tab. It defaults to 2
#
# DEBUG:
# .vim in home directory. configure to save in XDG way
# .viminfo
# - [ ] I need to add a version of .vimrc to CDG directory and delete the original if any
# mysdkman - wtd is this doign in home?
# .sdkman - move to XDG
#
# Down the line
# - [ ] Play with configurations to make things to your liking
# - - [ ] rofi ? wofi? dmanu substitute
# - - [ ] Note scraper and porper document / wirtings shortcut + twit via terminal
# - - [ ] Get Wall papers
# - - [ ] Projecct - colorscheme thatmatches wall papers
# Evevn more down the line
# Install Postgresql, steam, discord
#
# Lastly,
# - [ ] Ensure everything is installed in accordance to XDG folders
# - [ ] Test script is idempotent. Mayeb use VM for this?
# - [ ] Test instructions are all clear
#
# Then create your own ppa for all the software you install manually
#########################

sudo apt update
sudo apt upgrade

sudo apt install -y git curl

###################################################################################################
##  DOTFILES.                                                                                    ##
##-----------------------------------------------------------------------------------------------##
##  Downloads dotfiles, and creates backup of existing dotfiles in $XDG_CACHE_HOME/config-backup ##
##-----------------------------------------------------------------------------------------------##
##  Dotfiles use git submodule for noevim hece the --recurse-submodules and the submodule        ##
##  configurations to status, diff, and push.                                                    ##
##-----------------------------------------------------------------------------------------------##
##  References.                                                                                  ##
##  - https://www.atlassian.com/git/tutorials/dotfiles                                           ##
###################################################################################################
DOTFILES_GIT_DIR=$HOME/.dotfiles-git-config
function dotfig {
  git --git-dir=$DOTFILES_GIT --work-tree=$HOME $@
}
##--  Clones the .git files only  ---------------------------------------------------------------##
git clone --bare https://github.com/al3jandr0/dotfiles.git "$DOTFILES_GIT_DIR"
##--  Checksout the actual dotfiles.  This command may fail, see error handling below.  ---------##
dotfig checkout --recurse-submodules
##-----------------------------------------------------------------------------------------------##
##  Checkout would fail due to untracked files that would be overwritten. In such case:          ##
##  1) get git checkout error message.                                                           ##
##  2) extract file names (spaces .<filename>)                                                   ##
##  3) move the files into a backup directory                                                    ##
##-----------------------------------------------------------------------------------------------##
if [ $? -ne 0 ]; then
  mkdir -p "$XDG_CACHE_HOME/config-backup"
  dotfig checkout 2>&1 |
    sed -rn 's/^[[:space:]]+(.+)/\1/p' |
    xargs -I{} mv {} $XDG_CACHE_HOME/config-backup/{}
fi
dotfig checkout --recurse-submodules
if [ $? -ne 0 ]; then
  exit 1
fi
##--  git submodule friendly configurations  ----------------------------------------------------##
dotfig config status.showUntrackedFiles no
dotfig config status.submodulesummary 1
dotfig config diff.submodule log
dotfig config push.recurseSubmodules on-demand
# > git submodule update --remote --merge
##--  Creates XDG directories if they dont exist  -----------------------------------------------##
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_CACHE_HOME
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_STATE_HOME
mkdir -p $XDG_BIN_HOME

###################################################################################################
##  ESSENTIALS.                                                                                  ##
##-----------------------------------------------------------------------------------------------##
##  Good stuff that's essential and readily avialble in the pacakge manager                      ##
##-----------------------------------------------------------------------------------------------##
##  TODO. Add SSH agent. It should be default, nah?                                              ##
###################################################################################################
sudo apt install -y \
  bash \
  vim \
  ssh \
  alacritty \
  lsd \
  starship \
  direnv \
  jq \
  build-essential \
  make cmake cmake-extras \
  ninja-build \
  pulseaudio pavucontrol \
  network-manager
###################################################################################################
##  ESSENTIALS MANUAL INSTALLATOIN.                                                              ##
##-----------------------------------------------------------------------------------------------##
##  Good stuff that's essential and are not pakcaged                                             ##
##-----------------------------------------------------------------------------------------------##
##  Installation instructions.                                                                   ##
##  - Nerd Fonts. https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file                     ##
##  - McFly.      https://github.com/cantino/mcfly                                               ##
##  - Neovim.     https://github.com/neovim/neovim/releases/tag/v0.11.2                          ##
##-----------------------------------------------------------------------------------------------##
##  NERD FONTS.                                                                                  ##
##-----------------------------------------------------------------------------------------------##
mkdir -p $XDG_DATA_HOME/fonts
curl --output-dir $XDG_DATA_HOME/fonts -OL \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Mononoki.tar.xz
cd $XDG_DATA_HOME/fonts
tar -xvf Mononoki.tar.xz
rm -f Mononoki.tar.xz
fc-cache -fv
cd
##-----------------------------------------------------------------------------------------------##
##  MCFLY.                                                                                       ##
##-----------------------------------------------------------------------------------------------##
curl -L --output $FOREING_INSTALL_SCRIPTS_DIR/mcfly_install.sh \
  https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh
bash $FOREING_INSTALL_SCRIPTS_DIR/mcfly_install.sh \
  --git cantino/mcfly --to $XDG_BIN_HOME
cd
##-----------------------------------------------------------------------------------------------##
##  NEOVIM.                                                                                      ##
##  At the time of writing LazyVim requires a newer version of neovim that isn't available       ##
##  in the distro's packages, and I decieded to install it via snap isntead of donwloading the   ##
##  precompile archive becuase it requires a newer version og glibc than what's availble in      ##
##  my Debian 11 laptop.                                                                         ##
##  DEPENDENCIES.                                                                                ##
##  - Lazygit.    https://github.com/jesseduffield/lazygit?tab=readme-ov-file                    ##
##  - fzf.        https://github.com/junegunn/fzf                                                ##
##-----------------------------------------------------------------------------------------------##
sudo snap install nvim --classic
##  Lazygit  ------------------------------------------------------------------------------------##
if is_debian && [ "$VERSION_ID" -gt "12" ]; then
  sudo apt install lazygit
elif is_ubuntu; then
  sudo apt install lazygit
else
  LAZYGIT_VERSION="v0.52.0/lazygit_0.52.0_Linux_x86_64.tar.gz"
  LAZYGIT_REPO="https://github.com/jesseduffield/lazygit"
  curl -Lo lazygit.tar.gz "$LAZYGIT_REPO/releases/download/$LAZYGIT_VERSION" \
    --output-dir $FOREING_TOOL_REPO_DIR/lazygit
  cd $FOREING_TOOL_REPO_DIR/lazygit
  tar xf lazygit.tar.gz lazygit
  install lazygit -D -t $XDG_BIN_HOME
  cd
  unset LAZYGIT_VERSION
  unset LAZYGIT_REPO
fi
##  Fzf  ----------------------------------------------------------------------------------------##
if is_debian && [ "$VERSION_ID" -lt "12" ]; then
  FZF_VERSION="v0.63.0/fzf-0.63.0-linux_amd64.tar.gz"
  curl -Lo "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}" \
    --output-dir $FOREING_TOOL_REPO_DIR/fzf
  cd $FOREING_TOOL_REPO_DIR/fzf
  tar xf fzf.tar.gz
  install fzf -D -t $XDG_BIN_HOME
  cd
  unset FZF_VERSION
else
  sudo apt install fzf
fi

# TODO: Shared xclip and share its buffer with vim / nvim

###################################################################################################
##  NVIDIA.                                                                                      ##
##-----------------------------------------------------------------------------------------------##
##  The simplest command >sudo ubuntu-drivers install delegatest the choice of driver to         ##
##  ubuntu-drivers. However, I experieneced conflicts in which case the command returns an       ##
##  error and abort installation. It seems more reiable to specify the driver version.           ##
##  Note. ubuntu-drivers is not portable.                                                        ##
##        Alternativelly you could install manually via                                          ##
##        >apt install -u linux-objects-nvidia-570-server-open-$(uname -r)                       ##
##-----------------------------------------------------------------------------------------------##
##  TODO. Makse such that the latest version is auto-picked                                      ##
###################################################################################################
sudo ubuntu-drivers install nvidia:570

###############################################################################
##  WAYLAND.                                                                 ##
##---------------------------------------------------------------------------##
##  I've read online and on the wayland wiki that having the latest wayland  ##
##  protocols could fix screen tearing. Morever I need later versions of the ##
##  protocols in order to build Hyprland. So here they are built from soruce ##
##---------------------------------------------------------------------------##
##  TODO. Fix to pull latest. As of now the version is hardcoded             ##
###############################################################################
install_wayland_protocols

###############################################################################
##  HYPRLAND.                                                                ##
##---------------------------------------------------------------------------##
##  Installing from source because I want to try the latest version          ##
##  Consider ussing this ppa instead: https://github.com/cpiber/hyprland-ppa ##
##---------------------------------------------------------------------------##
##  Installing from this non-official ppa:                                   ##
##  https://github.com/cpiber/hyprland-ppa?tab=readme-ov-file                ##
##  ppa includes pakacges that are otherwise installed separatedly such as   ##
##  xdg-desktop-portal-hyprland and hyprwayland-scanner                      ##
##---------------------------------------------------------------------------##
## TODO. Investigate whether qt6 is still required to install manually for   ##
##       hyprlan                                                             ##
##---------------------------------------------------------------------------##
## TODO. What other hypr tools to install?                                   ##
###############################################################################
sudo add-apt-repository ppa:cppiber/hyprland
sudo apt update
# qt dependencies
sudo apt install -y qt6-wayland-dev qt6-base-dev
# hyprland dependencies
sudo apt install -y xdg-desktop-portal-hyprland hyprwayland-scanner
# hyperland & hypr tools
sudo apt install -y hyprland hyprlock waybar hyprpaper pipewire

###################################################################################################
##  PYTHON.                                                                                      ##
##-----------------------------------------------------------------------------------------------##
##  Installs                                                                                     ##
##  - latests python 3. Version provided by the distro                                           ##
##  - pip.  Distro version                                                                       ##
##  - pyenv.  Download other versions of python and auto switch virtual environments in          ##
##    conjunction with direnv                                                                    ##
##-----------------------------------------------------------------------------------------------##
##  pyenv can be installed maually. Here I choose apt's version for convenience                  ##
##-----------------------------------------------------------------------------------------------##
##  I delegate to the distros package manger to select the python system version. I consider     ##
##  this a safer approach.  As for my projects, I create virtual environments with the python    ##
##  of my choice. For this I use pyenv and direnv.                                               ##
##  For example, at the root of any project I have a .envrc and in there I add the commend       ##
##  'layout pyenv 3.x.y' which creates/and or acctivates a virtual env with the specified        ##
##  python version wehn I cd into the project's directory                                        ##
##  I do not use pyenv.                                                                          ##
##-----------------------------------------------------------------------------------------------##
##  Refernece:                                                                                   ##
##  - stackabuse.com/managing-python-environments-with-direnv-and-pyenv                          ##
##  - https://github.com/pyenv/pyenv?tab=readme-ov-file#installation                             ##
##-----------------------------------------------------------------------------------------------##
##  TODO. Consider adding Jupyter lab                                                            ##
###################################################################################################
export PYENV_ROOT=$XDG_DATA_HOME/pyenv
sudo apt install -y python3 python3-pip pyenv
# Installs latest pyenv manually
# mkdir -p $FOREING_TOOL_REPO_DIR/pyenv
# curl --output-dir $FOREING_TOOL_REPO_DIR/pyenv \
# -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer

###################################################################################################
##  DOCKER.                                                                                      ##
##-----------------------------------------------------------------------------------------------##
##  TODO. Pick between snap (apt) or Docker's inc ppa                                            ##
##-----------------------------------------------------------------------------------------------##
##  Ddocker is included in ubuntu's package manager, but it is a snap app.  And supposedly snap  ##
##  apps only have access to the $HOME directory, which is problematic because I often want to   ##
##  mount a project's working directory to a Docker container. I need to research this more for  ##
##  if such limitation is true, the snap version of docker would be imcompatible with my         ##
##  workflow, and I would isntall Docker vai Docker inc ppa                                      ##
##-----------------------------------------------------------------------------------------------##
##  Ppa-based instalation instructions:                                                          ##
##  www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04       ##
###################################################################################################

###################################################################################################
##  JAVA.                                                                                        ##
##-----------------------------------------------------------------------------------------------##
##  sdkman.  To maange and install JVM versions                                                  ##
##-----------------------------------------------------------------------------------------------##
##  Instructions: https://sdkman.io/install/                                                     ##
##-----------------------------------------------------------------------------------------------##
##  Disabled since it is not XDG compliant.                                                      ##
##  TODO. Organize sources and add variables to make it XDG compliant                            ##
###################################################################################################
#mkdir -p $FOREING_INSTALL_SCRIPTS_DIR
#curl --output $FOREING_INSTALL_SCRIPTS_DIR/sdkman_install.sh https://get.sdkman.io
#export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"
#mkdir -p $SDKMAN_DIR
#bash $FOREING_TOOL_REPO_DIR/sdkman_install.sh

###################################################################################################
##  NODEJS.                                                                                      ##
##-----------------------------------------------------------------------------------------------##
##  nvm.  To maange and install node js versions                                                 ##
##  npm and node js are install together via npm                                                 ##
##-----------------------------------------------------------------------------------------------##
##  PROFILE=/dev/null is to prevent the installation script from updating .bashrc                ##
##-----------------------------------------------------------------------------------------------##
##  Instructions: https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating       ##
###################################################################################################
curl --output $FOREING_INSTALL_SCRIPTS_DIR/nodejs_install.sh \
  https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh
PROFILE=/dev/null bash $FOREING_INSTALL_SCRIPTS_DIR/nodejs_install.sh

###################################################################################################
##  SDDM.                                                                                        ##
##-----------------------------------------------------------------------------------------------##
##  TODO. Remove SDDM                                                                            ##
##-----------------------------------------------------------------------------------------------##
##  ssdm seems flaky and slow while gdm works fine. Switching to gdm instead                     ##
###################################################################################################
#sudo apt install --no-install-recommends -y sddm
#sudo apt install -y qt6-5compat-dev \
#  qml6-module-qt5compat-graphicaleffects \
#  qt6-declarative-devqt6-svg-dev

###################################################################################################
##  VSCODE.                                                                                      ##
##-----------------------------------------------------------------------------------------------##
##  Chose to install Vs code via snap becuase that way updates happen in-app, and vscode has     ##
##  frequent updates.                                                                            ##
###################################################################################################
sudo apt install snapd
sudo snap install --classic code

###################################################################################################
##  LAPTOP HARDWARE.                                                                             ##
##-----------------------------------------------------------------------------------------------##
##  Hardware controlls almost exclusively for laptops                                            ##
##-----------------------------------------------------------------------------------------------##
##  TODO. Add Asus fan control and rgbg leds control stuff                                       ##
###################################################################################################
# Screen brightness
sudo apt install -y brightnessctl

###################################################################################################
##  RUNTIME CONFIGURATIONS.                                                                      ##
##-----------------------------------------------------------------------------------------------##
##  Configurations that can't be declared via config files / dorfiles                            ##
###################################################################################################

# Sets SDDM as the display manager
#sudo dpkg-reconfigure sddm

#postgres
#sqlite

# node / nvm and yarn
#lua?

## Others that I'd like to have but are not part of the package distribution for the diostro. ie.e require manual installation
#bats <- bash testing
#vscode

## Will be needed at some point but not essentials or are too heavy to includ in default
#jetbrainstoolbox
#virtualbox
#maven
#java
#sdkman

## Games
#lutris
#Steam
#Discord

# browsers
#brave

## Test if still needed
#brightness-udev
#ripgrep
