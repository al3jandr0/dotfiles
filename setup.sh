#!/bin/bash
set -e
# todo: add drivers shenanigans 
#### debian out of the box has shitty resolution
# increase windows lock tiemout

# todo: add dry run options

# 1. add yourself to the sudoers group
#### > su
#### > adduser $USER sudo
#### restart

FOREING_TOOL_REPO_DIR="./foreing-tool-repos"

sudo apt install bash git vim neovim curl

mkdir $FOREING_TOOL_REPO_DIR
git clone https://github.com/ryanoasis/nerd-fonts.git $FOREING_TOOL_REPO_DIR 

$FOREING_TOOL_REPO_DIR/nerd-fornts/install.sh "Mononoki Nerd Font" "Ubuntu Mono Nerd Font" 

# how about updating apt repo list for non-free libs
# it requires some coordination between foreing keys stored in /uset/share/keyrings/
#    and the repositories in /etc/apt/sources.list.d/ and 
# git
# nerd fonts
# xmonad
# xmobar
# allacritty
##  todo: update terminal selection to pick a defaul when allacritty is not available
# nvim
# lsd
# starship

# Other:
# node js
# next js
# vscode
# python 3
# pip3 <- with correct alias. Can this be backedup?
# pycharm
# firefox:wq
# dicord
# Elasticsearch? 
# Docker? docker install scipt




