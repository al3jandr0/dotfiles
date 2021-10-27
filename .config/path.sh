# set PATH so it icnludes Aws Amplify binaries if they exists
if [ -d "$HOME/.aplify/bin" ] && [[ $PATH != *"$HOME.aplify/bin"* ]]; then
    PATH="$HOME/.amplify/bin:$PATH"
fi

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
