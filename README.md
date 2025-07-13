# Dotfiles

```
curl -s "https://raw.githubusercontent.com/al3jandr0/dotfiles/refs/heads/master/setupv3.sh" | bash
```

> dotfiles and installation script

A project with dotfiles[^1] and setup script. It customizes a [desktop environment](https://wiki.archlinux.org/title/Desktop_environment) based on [Debian](https://en.wikipedia.org/wiki/Debian) and tailored to my preferences.

## Introduction

The goal of this repository is to maintian a portable[^2] desktop environment; one that is able to replicate the same customized desktop enviroment on any computer running Debian.

Most of the customizations are done with dotfiles, which are configuration files for applications. And protability is achieved by storing the dotfiles on this repository, and that way they can be copied over to other systems.  However dotfiles alone are insufficient to fully customize a desktop enviroment due to 2 limitations: some customizations are tailored to system-specific features, and dotfiles cannot install applications.

The script [setup.sh](./setup.sh) takes care of these limitations.  It generates system-specific configurations, installs applications, and downloads the dotfiles.

[^1]: **Dotfiles** are configuration files, and they are called like that because their names start with a `.`. For example, the Bash configuration file is '.bashrc'. dotfiles can be found either in the $HOME directory or in $HOME/.config.  Find more about dotfiles [here](https://wiki.archlinux.org/title/Dotfiles), [here](https://wiki.debian.org/DotFiles), and [here](https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory)
[^2]: The scripts and dotfiles found in this repo have only been tested on Debian 10 and 11 and running [Xorg](https://wiki.archlinux.org/title/Xorg)

## Key Features
- Installs and configures identical desktop environmnets on any computer running Debian
- Hands off installation script
- Easy to pick and choose apps to install
- [Xmonad](https://xmonad.org) tilling window manager
- [Xmobar](https://archives.haskell.org/projects.haskell.org/xmobar) status bar and lauch menu
- [Allacritty](https://github.com/alacritty/alacritty) terminal emulator
- [Neovim](https://neovim.io) text editor

## How to use

One way to use this repo is to browse the dotfiles and copy what you like.  Anotherone is to setup your desktop enviironment to look like mine using [setup.sh](./setup.sh).  The rest of the section is about the later option.

First, install Debian.  Then download [setup.sh](./setup.sh).

Before you run the script, make sure your user is in the super user group.  Most package installations require sudo privileges, and so does [setup.sh](./setup.sh)
```shell
# Check if you have sudo privileges
sudo -l -U $USER
```
To add yourself to the sudoers group.  You will need to restart for changes to take effect
```shell
# Run su and provide root password
su
# As super user, run
/sbin/adduser $USER sudo
```

Second, run setup.sh.  Make sure you have an internet connection. Installation may take some time as it donwloads many packages.

Setup.sh install packeges some from package manager (apt) other pre-build packages, sometimes source files that it the builds and isntalls, it writes some system config files, and downloads (clones) this repo

when the script finishes, log out or reboot. When you log back select Xmonad from the [display manager](https://wiki.debian.org/DisplayManager) menu. Enjoy!

Lastly, optional, backup to your own repository. 
-- Type git remote add upstream, and then paste the URL you copied in Step 2 and press Enter. It will look like this

then you can backup any updates on your own dotfiles repository

### How to modify and back up your changes
Example, Let say you ant to remove docker from appList
pwd

Edit setup.d/appList, remove the line with "Docker"

config status

config add 

config commit -m "Removes Docker from apps to install"

config push



## How it works

There are two components, one is the dotfiles, and the other is the [setup.sh](./setup.sh). 

All the files are backed up on a git repository, and to keep the home directory clean free of git files, I setup a separate tree (.git-config) that stores all the git files.

How it is setup git

use the alias config instead of git when working with this repository

Learn more: insert resources here

setup.sh is modular.  That is asides from essential packages

### XDG 
dotfiles are organized (for the most part) following the XDG Base Directory Specification ($HOME/.local, $HOME/.share, etc,).  For more information see here here here

The other part is the setup script setup.sh which is a bash script. The one key features is its modular and configuratble:  one can pick and choose the software that it installs except for some "essential" packages.

setup.d contains bash scripts to insteall a app / software / package etc.  Each file installs one appliation (docker, discord, vscode, etc.). 

setup.d/appList contains a list of all the scripts to run (apps to install). The files not in the list are not run by setup.sh.  If you dont wish to install any of these apps, you comment it out form appList.  note that setup.sh runs the scripts in the order they appear in appList, so beaware of dependencies

For more information about setup.sh try setup.sh --help


## `.local/bin` README

This repository also contains a handful of useful scripts under .local/bin.  Ideally I would have a README about those scrips in the same directory, but that is not a proper location fo read-only files since entire directory has execution rights, it is added to the path, and (by convention) it is really meant to store executables only.  This section functions as an embedded README file for those scripts. 

### [setup-monitor](./.config/bin/setup-monitor)
A script that switches to the largest monitor (screen), sets an appropriate dpi according to the screen's pixel count, and turns off the rest of the connected monitors if there are any.

Dependencies:
- [xorg](https://wiki.debian.org/Xorg)
- [xrandr](https://xorg-team.pages.debian.net/xorg/howto/use-xrandr.html)
- [xrdb](https://manpages.debian.org/jessie/x11-xserver-utils/xrdb.1.en.html)

#### Background
On default Debian, when plugging in a external monitor to my laptop, nothing displays on the external screen unless I manually enable it using some command line tool like xrandr.

Also when using an external monitor with higher pixel count than my lapto's (whcih is the case of my 4K external monitor), the dpi is not adjusted accordingly.  And it also needs to be set manually.

I constantly switch from using my laptop screen (1080p) while on the go and a bigger monitor (4K) while at my desk, and it is bothersome having to run a command manually every time I connect and disconnect my external monitor.  I only use one monitor at the time, and I want to switch between them automaticlally when the external monitor is plugged or unplugged.  I wrote [setup-monitor](./.config/bin/setup-monitor) for that purpose.

#### How it works
xrandr is an utility that lets you configure and view information about display ports[^3]

[setup-monitor](./.config/bin/setup-monitor) parses the output of xrandr -q and selects the larger (pixel count wise) display port, enables it (using xrandr), and turns off the rest of the connected display ports.

[setup-monitor](./.config/bin/setup-monitor) queries xrandr to find out about the availabe connected display ports, it enables the largest one (also using xrandr), and it turns off the rest of the connected display ports.

The `--dry-run` option lets you see the commands setup-monitor would execute and it doesn't produce side effects.  Try it to see how the script configures the display ports.

```shell
> xrandr -q
Screen 0: minimum 8 x 8, current 3840 x 2160, maximum 32767 x 32767
DVI-D-0 disconnected primary (normal left inverted right x axis y axis)
HDMI-0 connected 3840x2160+0+0 (normal left inverted right x axis y axis) 698mm x 393mm
   3840x2160     60.00*+  59.94    50.00    30.00    29.97    25.00    23.98    23.98
   2048x1152     60.00
   1920x1200     59.88
   1920x1080     60.00    59.94    50.00    23.98
   1680x1050     59.95
eDP-0 connected 1920x1080+0+0 (normal left inverted right x axis y axis) 100mm x 80mm
   1920x1080     60.00    59.94    50.00    23.98
   1680x1050     59.95
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-1 disconnected (normal left inverted right x axis y axis)
```

```shell
> xrandr -q | bash setup-monitor --dry-run
xrandr --output HDMI-0 --mode 3840x2160 --dpi 144
echo 'Xft.dpi: 144' > /tmp/dpi.fjCppenD5
xrdb -override /tmp/dpi.fjCppenD5
xrandr --outupt eDP-0 --off
```
Lets break down the output:
1. `xrandr --output HDMI-0 --mode 3840x2160 --dpi 144` Enables the display port `HDMI-0` with resolution `3840x2160` and dpi `144`

2. `echo 'Xft.dpi: 144' > /tmp/dpi.fjCppenD5` Writes to a temporary file with the X font dpi property set to 144. `Xft.dpi` controls the dpi for font (text).  Setting the display port dpi via xrandr is not sufficient, and setting the font dpi is necesary.

3. `xrdb -override /tmp/dpi.fjCppenD5` Loads the X server's font property by loading the temporary file.

4. `xrandr --outupt eDP-0 --off` Turns off the diplay port `eDP-0`.

Try `setup-monitor --help` for more information.

To switch monitors automatically upon login I invoke [setup-monitor](./.config/bin/setup-monitor) from [.profile](./.profile) by adding these 3 lines:
```shell
if which xrandr > /dev/null; then
    xrandr --q12 | bash .local/bin/setup-monitor
fi
```

[^3]: It is an abstraction (htink of the socket where you plug a computer monitor cable). Not to be confused about the digital display interface (DP).

#### Future work
- [ ] Parse the modes of each display port
- [ ] Handle tiebreaks for the case when there is more than 1 connected display port with the same pixel size
- [ ] Compute dpi based on both physical screen size and pixel count
- [ ] Update readme to include how to run script upon events

### References

* https://www.thinkwiki.org/wiki/Xorg_RandR_1.2  Xrandr wiki page. It contains sample commands
* https://linuxreviews.org/HOWTO_set_DPI_in_Xorg  A helpful guide how to set dpi in xorg
* https://gitlab.freedesktop.org/xorg/app/xrandr  Xrandr's source code.  It is the only place I found out the definitions of xrandr query output.

---








