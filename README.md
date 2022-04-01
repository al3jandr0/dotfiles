# Dotfiles

> dotfiles and desktop environment setup

A project with dotfiles and installation script (setup.sh) to install apps, and configure a linux desktop environment based on Debian tailor to my liking.

Colapsable Table of contents (optional)

## Introduction

The goal of this project is to have a portable* desktop environment; this project should be able to setup -- install and configure -- the exact same desktop environment on any computer with Debian installed.

One piece of the project is the dotfiles, which are configuration files for applications. They are usual named with a '.' suffix hence the name. Though many configuration files aren't name with the '/' suffix and exists under the directory .config.  you can read more about dotfiles here, here, and here

The other piece of the project is the installation script (setup.sh) that takes care of installing apps, downloading the dotfiles and creating configurations that require super user privileges.

*- caveats: Limited to Debain and Debian based Linux

## Key Features
- Installs and configures identical desktop environmnets on any computer running Debian
- Requires little to no intervention.  Run the setup script and done
- Modular installation script; it is easy to customize
- Pick and choose apps to install without coding, just edit the list of apps to install (appList)
- Xmonad tiled window manager
- Xmobar menu (caveat)
- Allacritty terminal
- Neovim editor

## How to use

You could browse the dotfles, copy them, etc.  Or you could choose to setup your desktop environment to look like mine :)

First, install Debian

WARNING: Setup.sh has only been tested on Debian. Morever it uses apt to install packages, so it is limited to work on Debain based operating systems.  It is plausible to replace usages of apt for X Y and make it work on Arch, Fedora or other distros.

Then, download setup.sh.  Easdy download link OR curl command

Before you run it, make sure you are in the super user group.  Most package installations require sudo privileges, and so does setup.sh

-- Insert snipped on how to add your user to superuser --

Second, run setup.sh.  Make sure you have an internet connection. Installation may take some time as it donwloads many packages.  Setup.sh install packeges some from package manager (apt) other pre-build packages, sometimes source files that it the builds and isntalls, it writes some system config files, and downloads (clones) this repo

And you are done. you can reboot, and when you log back in select Xmonad from teh diplay manager menu
-- Reference: https://wiki.debian.org/DisplayManager

Lastly, optional. For the repository to make it your own
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

There are two parts, one is the dotfiles, and the other is the setup.sh. 

all the dotfiles and scripts are backed up on a git repository, and to keep home clean (ish) I setup a separate tree (.git-config) that stores all the git files.

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


## .local/bin README

This repository also contains a handful of useful scripts under .local/bin.  However this is not a proper location to have a README file because the entire directory has execution rights, and it is added to the path.  Therefore this section functions as an embedded README file for those scripts. 

### setup-monitor
A script that switches to the largest monitor (screen) available and turns off the rest (if there are more than one connected).

#### Background
When plugging in a external monitor to my laptop, nothing displays on the external screen unless I manually set it on using some tool like xrandr

When using an external monitor with higher pixel count, the dpi is not adjusted accordingly.

I constantly switch from using my laptop screen (1080p) while on the go and a bigger monitor (4K) while at my desk, and it is bothersome having to run a command manually every time I connect and disconnect my external monitor.

#### Intro and motivation
I only use 1 monitor at time; I use either my laptop's built-in monitor (1080p) or an external monitor (4K).  This script enables signal to the larges monitor and disables the smaller ones, and it sets an appropriate dpi according to the screen's pixel count.

#### How it works

Dependencies 

- xrandr
- xrdb

xrandr is an utility that provides information about the display ports, and it lets you configure them.

with xrandr -q prints information about your system display ports.

Show output here

setup-monitor parses the output of xrandr -q and selects the larger (pixel count wise) display port, enables it (using xrandr), and turns off the rest of the connected display ports.

the --dry-run option lets you see the commands setup-monitor would execute and it doesn't produce side effects

example out put of setup-monitor --dry-run

Explain the commands

Try setup-monitor --help for more info



#### How to use / examples

xrandr -q | setup-monitor

xrandr -1 | bash setup-monitor



### References

https://www.thinkwiki.org/wiki/Xorg_RandR_1.2

https://linuxreviews.org/HOWTO_set_DPI_in_Xorg

https://gitlab.freedesktop.org/xorg/app/xrandr/-/blob/master/xrandr.c

### Future work / todo

[ ] Parse the modes of each display port

[ ] Handle tiebreaks for the case when there is more than 1 connected display port with the same pixel size

[ ] Compute dpi based on both physical screen size and pixel count



## Contact











