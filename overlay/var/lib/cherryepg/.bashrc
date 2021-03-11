# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

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

function realpath()
{
    f=$@

    if [ -d "$f" ]; then
        base=""
        dir="$f"
    else
        base="/$(basename "$f")"
        dir=$(dirname "$f")
    fi

    dir=$(cd "$dir" && /bin/pwd)

    echo "$dir$base"
}

# Set prompt path to max 2 levels for best compromise of readability and usefulness
promptpath () {
    realpwd=$(realpath $PWD)
    realhome=$(realpath $HOME)

    # if we are in the home directory
    if echo $realpwd | grep -q "^$realhome"; then
        path=$(echo $realpwd | sed "s|^$realhome|\~|")
        if [ "$path" = "~" ] || [ "$(dirname "$path")" = "~" ]; then
            echo $path
        else
            echo $(basename $(dirname "$path"))/$(basename "$path")
        fi
        return
    fi

    path_dir=$(dirname "$PWD")
    # if our parent dir is a top-level directory, don't mangle it
    if [ $(dirname "$path_dir") = "/" ]; then
        echo $PWD
    else
        path_parent=$(basename "$path_dir")
        path_base=$(basename "$PWD")

        echo $path_parent/$path_base
    fi
}

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias ll='ls --color=auto -alF'
    alias la='ls --color=auto -A'
    alias l='ls --color=auto -l'
    alias grep='grep --color=auto --ignore-case'
    alias fgrep='fgrep --color=auto --ignore-case'
    alias egrep='egrep --color=auto --ignore-case'

    # Set a terminal prompt style (default is fancy color prompt)
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h \[\033[01;34m\]$(promptpath)\[\033[00m\]\$ '
else
    alias ls="ls -F"
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    PS1='${debian_chroot:+($debian_chroot)}\u@\h $(promptpath)\$ '
fi

export GIT_AUTHOR_NAME="cherry-"$(hostname)
export GIT_AUTHOR_EMAIL="info@cherryhill.eu"
export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL

[ -d /usr/lib/git-core ] && export PATH=/usr/lib/git-core:$PATH

git_branch_bin=$(which git-branch 2>/dev/null)
function git-branch()
{
    local delete=no
    for arg; do
        [ "$arg" == "-D" ] && delete=yes
    done
    if [ "$delete" == "yes" ]; then
        $git_branch_bin -v $*
    else
        $git_branch_bin -v -a $*
    fi
}

# useful aliases
alias gs="git status -bs"
alias gd="git difftool -d"
alias ga="git add"
alias gb="git branch -avv"
alias gc="git commit -v"
alias gca="git commit -am"
alias gstashed="git stash list --pretty=format:'%gd: %Cred%h%Creset %Cgreen[%ar]%Creset %s'"
alias gl="git log --graph --oneline --date-order --decorate --color --all"
alias gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"
export PERL5LIB="$HOME/cherryTool/lib:$PERL5LIB"
export PATH="$PATH:$HOME/cherryTool/bin"

export DANCER_ENVIRONMENT=production

# start tmux alias screen on login
sleep 2
tmux attach &> /dev/null
