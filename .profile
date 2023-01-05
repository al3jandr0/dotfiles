# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
# configures monitor (screen) sets resolution (mode) and dpi
if which xrandr > /dev/null; then
    xrandr --q12 | bash .local/bin/setup-monitor
fi

# TODO: look into creating a ~/.xinitrc file
# Increments key repetition rate
# 200 - milisecond delay before repeating starts
# 50  - rate of repetition
xset r rate 200 50

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
else
    if [ -f "$HOME/.config/path" ]; then
        . "$HOME/.config/path.sh"
    fi
fi

