# set PATH so it includes cabal-built (haskell) binaries if it exists
if [ -d "$HOME/.cabal/bin" ] && [[ $PATH != *"$HOME/.cabal/bin"* ]]; then
    PATH="$HOME/.cabal/bin:$PATH"
fi

# sets PATH so it includes cargo tools (rust) if they exist
if [ -d "$HOME/.cargo/bin" ] && [[ $PATH != *"$HOME/.cargo/bin"* ]]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] && [[ $PATH != *"$HOME/bin"* ]]; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] && [[ $PATH != *"$HOME/.local/bin"* ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$XDG_DATA_HOME/JetBrains/Toolbox/scripts" ] && [[ $PATH != *"$XDG_DATA_HOME/JetBrains/Toolbox/scripts"* ]]; then
    PATH="$XDG_DATA_HOME/JetBrains/Toolbox/scripts:$PATH"
fi

# set PATH so it includes jdk version
if [ -d "$JAVA_HOME" ] && [[ $PATH != *"$JAVA_HOME"* ]]; then
    PATH="$JAVA_HOME/bin:$PATH"
fi

# set PATH so it includes jdk version
if [ -d "$MAVEN_HOME" ] && [[ $PATH != *"$MAVEN_HOME"* ]]; then
    PATH="$MAVEN_HOME/bin:$PATH"
fi

# TODO: delete. scala is not for me
# coursier directory of Scala tools
if [ -d "$HOME/.local/share/coursier/bin" ] && [[ $PATH != *"coursier/bin"* ]]; then
    PATH="$HOME/.local/share/coursier/bin:$PATH"
fi

# set PATH so it includes nvm directory if it exists
#if [ -d "$HOME/.nvm" ] && [[ $PATH != *"$HOME/.nvm"* ]]; then
#    PATH="$HOME/.nvm:$PATH"
#fi
#

# set PATH to include pyenv binaries
if [ -d "$XDG_DATA_HOME/pyenv/bin" ]; then
    PATH="$XDG_DATA_HOME/pyenv/bin:$PATH"
fi

# set PATH to include pyenv binaries
if [ -d "$XDG_DATA_HOME/cosmocc/bin" ]; then
    PATH="$XDG_DATA_HOME/cosmocc/bin:$PATH"
fi
