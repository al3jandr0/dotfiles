#!/usr/bin/env bash
#
#                   _      ______     _ _____   ____ _______ _____
#             /\   | |    |  ____|   | |  __ \ / __ \__   __/ ____|
#            /  \  | |    | |__      | | |  | | |  | | | | | (___
#           / /\ \ | |    |  __| _   | | |  | | |  | | | |  \___ \
#          / ____ \| |____| |___| |__| | |__| | |__| | | |  ____) |
#         /_/    \_\______|______\____/|_____/ \____/  |_| |_____/
#
#
#                    Alejandro's configurtion of Ubuntu
#
#
#  ABOUT.
#
#  This is the installation scriptp for my custom desktop environment; it installs programs and  ##
#  download my dotfies.
#
#  My configurations are tailored for software develoment, so you will find many programs used   ##
#  for software developement such as databases, editors, language interpreters, etc.
#
#  I also play games, so you will find that Steam and Discord are installed.
#
#  The script is well documented, and while it is long, most lines are comments explaining my
#  rational behind my choices.  You should be able to edit and customize the scriptp to your
#  liking.
#
#
#  WHATS INCLUDED.
#
#  SUMMARY
#    Display Manager:         Ubuntu's & debian default (GDM)
#    Tiling window manager:   Ubuntu's & Debian's (Gnome), Hyprland
#    Editor:                  NeoVim, vim, vscode
#    Agent:                   sshagent (over gpg agent)
#    Daemon manager:          systemd (Ubuntu's & Debian default)
#
#  PROGRAMS
#
#  AFTER INSTALLATION & CUSTOMIZATION
#
#  Explain the dots aliasing
#
###################################################################################################
# TODO:
# - [ ] Switch gpus
# - [ ] GRUB. overrite defaults with custome
# - - [ ] TODO. Make note of this
#         kernel options: no splash, and non-quiet -> may need to disable plymouth. didnt need to disanble it just setting the defualt boot otions to "" was enough
# - - [ ] disable fwupd.service <- systemd
# - - [ ] disable apt-daily-upgrade.service, disable apt-daily-upgrade.timer
# - - [x] disable systemd-networkd-wait-online.service https://askubuntu.com/questions/1166486/how-to-decrease-the-boot-time
# - [ ] Control the laptops many leds and fancy lights
# - [ ] Add lists of programs in this file
# - [ ] Nvim. spaces as tab. It defaults to 2
# - [ ] Git. Store .gitconfig (global) in a XDG compliant location
# FIX:
# - [ ] Quiting hyprland is slow, though I suspect the quiting part is quick and gdm comes up very slowly
# - [ ] Node / NVM. fix bashrc. Installation iscript is not running or not installing any files
# - [ ] Nice to have: speed up starhip promt - ther eis a visible delay from when the terminal shows up and
#       when the prompt appears
# - [ ] NeoVim.
# - - [ ] ast-grep
# - [ ] sdkman. PR to Project (no java yet).
#
# Hyprland:
# - Add lock Screen
# - Setup desktop background
# - Configure xclip / shared buffer
# - setup commandC and cpmmand V as copy pasta
# - Prettyfy waybar
# - Add arrow navigation beween desktops
#
#
# Down the line
# - [ ] Play with configurations to make things to your liking
# - - [ ] rofi ? wofi? dmanu substitute
# - - [ ] Note scraper and porper document / wirtings shortcut + twit via terminal
# - - [ ] Get Wall papers
# - - [ ] Projecct - colorscheme thatmatches wall papers
#
# - [ ] Docker. install via script but uptionally bc it is heavy. use whichever
#               app that doenst limit the mouting directory
#
# Evevn more down the line. Install Postgresql (when needed), steam, discord
# - [ ] vscode. Pre-select some plugins ?
#########################

set -x

###################################################################################################
##  VARS.                                                                                        ##
##-----------------------------------------------------------------------------------------------##
##  XDG.                                                                                         ##
##  Directory reference guide:                                                                   ##
##  https://wiki.archlinux.org/title/XDG_Base_Directory                                          ##
###################################################################################################
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
XDG_BIN_HOME=${XDG_BIN_HOME:-$HOME/.local/bin}
##-----------------------------------------------------------------------------------------------##
##  CUSTOM.                                                                                      ##
##  - REPO_DIR.  Directory to download program sources for programs that are build from source   ##
##  - BIN_DIR.  Direcotry to download pre-compiled (usually compressed) binaries                 ##
##  - INSTALL_SCRIPT_DIR.  Directory to download installation scripts                            ##
##-----------------------------------------------------------------------------------------------##
##  Notes.                                                                                       ##
##  I decided to persist the downloaded content because it is useful for troubleshooting         ##
##  Therefore this script makes no effort to delete them after installation completes.           ##
##  However, it is safe to delete the files under $XDG_CACHE_HOME/dotfiles-installation          ##
##-----------------------------------------------------------------------------------------------##
REPO_DIR="$XDG_CACHE_HOME/dotfiles-installation/repositories"
INSTALL_SCRIPT_DIR="$XDG_CACHE_HOME/dotfiles-installation/scripts"
BIN_DIR="$XDG_CACHE_HOME/dotfiles-installation/bin"
##-----------------------------------------------------------------------------------------------##
##  OS.                                                                                          ##
##-----------------------------------------------------------------------------------------------##
[ -f /etc/os-release ] && . /etc/os-release

###################################################################################################
##  FUNCTIONS.                                                                                   ##
###################################################################################################
##-----------------------------------------------------------------------------------------------##
##  Returns 0 (sucess) if the OS is Debian                                                       ##
##  Usage: if is_debian; then ...                                                                ##
##  See. /etc/os-release                                                                         ##
##-----------------------------------------------------------------------------------------------##
is_debian() {
  test -n "$ID" && test "$ID" == "debian"
}
##-----------------------------------------------------------------------------------------------##
##  Returns 0 (sucess) if the OS is Ubuntu                                                       ##
##  Usage: if is_ubuntu; then ...                                                                ##
##  See. /etc/os-release                                                                         ##
##-----------------------------------------------------------------------------------------------##
is_ubuntu() {
  test -n "$ID" && test "$ID" == "ubuntu"
}
##-----------------------------------------------------------------------------------------------##
##  Returns 0 (sucess) when a command can be invoked in bash shell                               ##
##  Usage: if package_isntalled "package-name"; then ...                                         ##
##  WARNNING. Not POSIX compliant                                                                ##
##  TODO. Remove if not needed                                                                   ##
##-----------------------------------------------------------------------------------------------##
command_exists() {
  command -v "$@" >/dev/null 2>&1
}
##-----------------------------------------------------------------------------------------------##
##  Returns 0 (sucess) when a package is isntalled                                               ##
##  Usage: if package_isntalled "package-name"; then ...                                         ##
##-----------------------------------------------------------------------------------------------##
package_installed() {
  dpkg -s "$@" >/dev/null 2>&1
}
##-----------------------------------------------------------------------------------------------##
##  Returns 0 (sucess) when the argument is a file                                               ##
##  Usage: if file_exists "path/to/file"; then ...                                               ##
##-----------------------------------------------------------------------------------------------##
file_exists() {
  test -f "$@" >/dev/null 2>&1
}
##-----------------------------------------------------------------------------------------------##
##  Returns 0 (sucess) when the argument is a directory                                          ##
##  Usage: if dir_exists "path/to/dir"; then ...                                                 ##
##-----------------------------------------------------------------------------------------------##
dir_exists() {
  test -d "$@" >/dev/null 2>&1
}
##########################
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
  git --git-dir=$DOTFILES_GIT_DIR --work-tree=$HOME $@
}
# TODO: improve upon dotfile repo check
if [ ! -d "$DOTFILES_GIT_DIR" ]; then
  mkdir -p $DOTFILES_GIT_DIR
  ##--  Clones the .git files only  -------------------------------------------------------------##
  git clone --bare https://github.com/al3jandr0/dotfiles.git "$DOTFILES_GIT_DIR"
fi
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
  dotfig checkout --recurse-submodules
fi
dotfig submodule update --remote --merge --init
##--  git submodule friendly configurations  ----------------------------------------------------##
dotfig config status.showUntrackedFiles no
dotfig config status.submodulesummary 1
dotfig config diff.submodule log
dotfig config push.recurseSubmodules on-demand
##--  Creates XDG directories if they dont exist  -----------------------------------------------##
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_CACHE_HOME
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_STATE_HOME
mkdir -p $XDG_BIN_HOME
##--  Scripts runtime cache directories  --------------------------------------------------------##
mkdir -p $REPO_DIR
mkdir -p $BIN_DIR
mkdir -p $INSTALL_SCRIPT_DIR
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
  network-manager \
  imagemagick \
  pandoc \
  nvtop
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
curl -L --output $INSTALL_SCRIPT_DIR/mcfly_install.sh \
  https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh
bash $INSTALL_SCRIPT_DIR/mcfly_install.sh \
  --git cantino/mcfly --to $XDG_BIN_HOME --force
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
##  - Ripgrep     https://github.com/BurntSushi/ripgrep?tab=readme-ov-file#installation          ##
##  - fd-find     https://github.com/sharkdp/fd                                                  ##
##  - Texlive     https://wiki.debian.org/TeXLive                                                ##
##  - ast-grep    ???                                                                            ##
##-----------------------------------------------------------------------------------------------##
sudo snap install nvim --classic
##--  Lazygit  ----------------------------------------------------------------------------------##
#if is_debian && [ "$VERSION_ID" -gt "12" ]; then
#  sudo apt install lazygit
#elif is_ubuntu && [ 1 -eq "$(echo "25.04 < $VERSION_ID" | bc)" ]; then
#  sudo apt install -y lazygit
LAZYGIT_VERSION="v0.52.0/lazygit_0.52.0_Linux_x86_64.tar.gz"
LAZYGIT_REPO="https://github.com/jesseduffield/lazygit"
mkdir -p $BIN_DIR/lazygit
curl -Lo lazygit.tar.gz "$LAZYGIT_REPO/releases/download/$LAZYGIT_VERSION" \
  --output-dir $BIN_DIR/lazygit
cd $BIN_DIR/lazygit
tar xf lazygit.tar.gz lazygit
install lazygit -D -t $XDG_BIN_HOME
cd
unset LAZYGIT_VERSION
unset LAZYGIT_REPO
##--  Fzf  --------------------------------------------------------------------------------------##
if is_debian && [ "$VERSION_ID" -lt "12" ]; then
  FZF_VERSION="v0.63.0/fzf-0.63.0-linux_amd64.tar.gz"
  mmkdir -p $BIN_DIR/fzf
  curl -Lo "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}" \
    --output-dir $BIN_DIR/fzf
  cd $BIN_DIR/fzf
  tar xf fzf.tar.gz
  install fzf -D -t $XDG_BIN_HOME
  cd
  unset FZF_VERSION
else
  sudo apt install -y fzf
fi
##--  Others  -----------------------------------------------------------------------------------##
sudo apt install -y ripgrep fd-find texlive

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
###################################################################################################
sudo ubuntu-drivers install nvidia

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
##---------------------------------------------------------------------------##
##  Installs (per line):                                                     ##
##  1. qt dependencies                                                       ##
##  2. hyprland dependencies                                                 ##
##  3. hyprland components                                                   ##
##---------------------------------------------------------------------------##
sudo apt install -y \
  qt6-wayland-dev qt6-base-dev \
  xdg-desktop-portal-hyprland hyprwayland-scanner wayland-protocols \
  hyprland hyprlock waybar hyprpaper pipewire

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
# mkdir -p $REPO_DIR/pyenv
# curl --output-dir $REPO_DIR/pyenv \
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
#mkdir -p $INSTALL_SCRIPT_DIR
#curl --output $INSTALL_SCRIPT_DIR/sdkman_install.sh https://get.sdkman.io
#export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"
#mkdir -p $SDKMAN_DIR
#bash $REPO_DIR/sdkman_install.sh

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
curl --output $INSTALL_SCRIPT_DIR/nodejs_install.sh \
  https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh
PROFILE=/dev/null bash $INSTALL_SCRIPT_DIR/nodejs_install.sh

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
##  SSH AGENT.                                                                                   ##
##-----------------------------------------------------------------------------------------------##
##  I use systemd to manage the ssh agent and the configuration that is included in the          ##
##  ubuntu/debian distro.  They configuration is: /usr/lib/systemd/system/ssh.service.           ##
##-----------------------------------------------------------------------------------------------##
##  Ugh. I may need to do this anyway. See                                                       ##
##  https://unix.stackexchange.com/questions/315004/where-does-gnome-keyring-set-ssh-auth-sock   ##
##  An alternative would be storing the configuration file in                                    ##
##  XDG_CONFIG_HOME and using XDG_RUNTIME_DIR for socket location.  This other apporach should   ##
##  be more portable.                                                                            ##
##  References:                                                                                  ##
##  - https://www.baeldung.com/linux/ssh-agent-systemd-unit-configure                            ##
##-----------------------------------------------------------------------------------------------##
##  Commands:                                                                                    ##
##  - Get status: sudo systemctl status ssh                                                      ##
##  - Start:      sudo systemctl start ssh                                                       ##
##  - Stopt:      sudo systemctl stop ssh                                                        ##
###################################################################################################
##-- disbales gpg agent for socket  -------------------------------------------------------------##
sudo systemctl --global mask gpg-agent-ssh.socket
sudo systemctl daemon-reload
##-- Enables ssh service to autostart  ----------------------------------------------------------##
sudo systemctl enable ssh

###################################################################################################
##  MISC SERVICES.                                                                               ##
###################################################################################################
##  NetworkManager-wait-online.service.                                                          ##
##  Prevents booting until online.                                                               ##
##  Ref. https://askubuntu.com/questions/1018576/what-does-networkmanager-wait-online-service-do ##
##-----------------------------------------------------------------------------------------------##
sudo systemctl disable NetworkManager-wait-online.service
