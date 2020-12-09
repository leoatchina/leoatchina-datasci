#!/bin/bash
# File              : .bashrc
# Author            : leoatchina <leoatchina@outlook.com>
# Date              : 2020.12.08
# Last Modified Date: 2020.12.08
# Last Modified By  : leoatchina <leoatchina@outlook.com>

export PATH=/sbin:/usr/sbin:/bin:/usr/local/bin:/usr/bin

export CLICOLOR=1
export LSCOLORS=GxFxBxDxCxegedabagaced

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


export EDITOR=vim
export TERM=xterm-256color

# export LANG='zh_CN.UTF-8'
# export LC_ALL='zh_CN.UTF-8'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    alias ls='/bin/ls --color=auto'
    alias ll='/bin/ls -lh --color=auto'
    alias lsa='/bin/ls -alh --color=auto'
    alias llt='/bin/ls -lthr --color=auto'
    alias llT='/bin/ls -lth --color=auto'
    alias lls='/bin/ls -lShr --color=auto'
    alias llS='/bin/ls -lSh --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
if [ -x "$(command -v git)" ]; then
    git_branch() {
        branch="`git branch 2>/dev/null | grep "^\*" | sed -e "s/^\*\ //"`"
        if [ "${branch}" != "" ];then
            if [ "${branch}" = "(no branch)" ];then
                branch="(`git rev-parse --short HEAD`...)"
            fi
            if [[ `git status --porcelain` ]] ; then
                branch=$branch" x"
            else
                branch=$branch" o"
            fi
            echo " $branch"
        fi
    }
    export PS1="\[\e[31;1m\]\u\[\e[0m\]@\[\e[33;1m\]\h\[\e[0m\]:\[\e[36;1m\]\w\[\e[0m\]\[\e[30;1m\]\$(git_branch)\[\e[0m\]\n\$ "
else
    export PS1="\[\e[31;1m\]\u\[\e[0m\]@\[\e[33;1m\]\h\[\e[0m\]:\[\e[36;1m\]\w\[\e[0m\]\n\$ "
fi

if [[ ! -v $JUPYTER_SERVER_ROOT ]] && [[ ! $PATH == */opt/miniconda3/bin* ]]; then
    export PATH=/opt/miniconda3/bin:$PATH
fi
export JUPYTERLAB_DIR=$HOME/.jupyterlab

if [[ ! $PATH == */$HOME/.local/bin* ]]; then
    export PATH=$HOME/.local/bin:$PATH
fi

[ -f /usr/local/etc/bash_completion ] && bash /usr/local/etc/bash_completion
[ -f $HOME/.configrc ] && source $HOME/.configrc
