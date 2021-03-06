# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

BLUE="\[\033[0;34m\]"
# OPTIONAL - if you want to use any of these other colors:
RED="\[\033[0;31m\]"
LIGHT_RED="\[\033[1;31m\]"
GREEN="\[\033[0;32m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;37m\]"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
force_color_prompt=yes

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

function get_vim_server_name {
    CURRENT_GIT_BRANCH=`git rev-parse --abbrev-ref HEAD 2> /dev/null`

    if [ -z $CURRENT_GIT_BRANCH ]; then
        VIM_SERVER='default'
    else
        CURRENT_GIT_BRANCH_BASE_NAME=`git rev-parse --show-toplevel`
        CURRENT_GIT_BRANCH_BASE_NAME=`basename $CURRENT_GIT_BRANCH_BASE_NAME`
        VIM_SERVER=$CURRENT_GIT_BRANCH_BASE_NAME$CURRENT_GIT_BRANCH
    fi
    echo -en $VIM_SERVER
}

function V {
    VIM_SERVER=$(get_vim_server_name)
    gvim --servername $VIM_SERVER --remote_silent $@
}

function parse_git_branch {
	GB=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	#GO=`git remote show origin  2> /dev/null|grep Fetch |sed -e 's/Fetch URL: \(.*\)/\1/'`
	GO=""
	#GSTATUS=`git status 2> /dev/null`
	GMODIFIED=`git status 2> /dev/null | grep "modified:"|grep -v untracked |wc -l`
	GMODIFIED=" \xe2\x9d\x8d"$GMODIFIED
	GNEW=`git status 2> /dev/null |grep "new file"|wc -l`
	GNEW=" \xe2\x9c\xb7"$GNEW
	GDELETED=`git satatus 2> /dev/null |grep "deleted"|wc -l`
	GDELETED=" \xe2\x9c\x9d"$GDELETED
	#GMODIFIED=""
	#GNEW=""
	#GDELETED=""
	GR=""
	if [ "$GB" ]; then
		GB="\n\\033[0m\xe2\x94\x9c\xe2\x95\xbc\033[00;31m$GB \xe2\x86\x92 \033[00;33m$GMODIFIED$GNEW$GDELETED"
	fi
	if [ "$GO" ]; then
		GO="\n\\u251c\\u257c\033[01;31m$GO"
	fi
	GR=$GO$GB

	echo -en $GR
}

if [ "$color_prompt" = yes ]; then
	PS1='\342\224\214\342\224\200${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w'
	PS1=$PS1'\[$(parse_git_branch)\]'
	PS1=$PS1'\n\[\033[0;37m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]'
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

source ~/.bashrc_local
