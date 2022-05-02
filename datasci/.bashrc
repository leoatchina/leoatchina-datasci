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

if [[ ! $PATH == */$HOME/.local/bin* ]]; then
    export PATH=$HOME/.local/bin:$PATH
fi

[ -f /usr/local/etc/bash_completion ] && bash /usr/local/etc/bash_completion
[ -f $HOME/.configrc ] && source $HOME/.configrc
