# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi
unset color_prompt force_color_prompt
export TERM=xterm-256color

function git_branch {
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

alias ls='/bin/ls --color=auto'
alias ll='/bin/ls -lh --color=auto'
alias lsa='/bin/ls -alh --color=auto'
alias llt='/bin/ls -lthr --color=auto'
alias llT='/bin/ls -lth --color=auto'
alias lls='/bin/ls -lShr --color=auto'
alias llS='/bin/ls -lSh --color=auto'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
export PS1="\[\e[31;1m\]\u\[\e[0m\]@\[\e[33;1m\]\h\[\e[0m\]:\[\e[36;1m\]\w\[\e[0m\]\[\e[30;1m\]\$(git_branch)\[\e[0m\]\n\$ "

if [[ ! -v $JUPYTER_SERVER_ROOT ]] && [[ ! $PATH == /opt/anaconda3/bin* ]]; then
    export PATH=/opt/anaconda3/bin:$PATH
fi

if [[ ! $PATH == */root/bin* ]]; then
    export PATH=$PATH:/root/bin
fi

[ -f /usr/local/etc/bash_completion ] && bash /usr/local/etc/bash_completion
[ -f /root/.configrc ] && source /root/.configrc
