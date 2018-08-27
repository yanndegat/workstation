#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
export GOPATH=/home/centos/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# enable local vim
if [ -d "$HOME/.local/vim/bin/" ] ; then
  PATH="$HOME/.local/vim/bin/:$PATH"
  export EDITOR=/home/centos/.local/vim/bin/vim
fi

# enable local emacs
if [ -d "$HOME/.local/emacs/bin/" ] ; then
  PATH="$HOME/.local/emacs/bin/:$PATH"
  if [ -x /home/centos/.local/emacs/bin/emacsclient.sh ]; then
    export EDITOR=/home/centos/.local/emacs/bin/emacsclient.sh
    alias e=$EDITOR
  fi
fi

# enable local tmux
if [ -d "$HOME/.local/tmux/bin/" ] ; then
  PATH="$HOME/.local/tmux/bin/:$PATH"
fi

# added by travis gem
[ -f /home/centos/.travis/travis.sh ] && source /home/centos/.travis/travis.sh
