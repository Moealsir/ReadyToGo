# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
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

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi



#mygithub
gituser=Moealsir
gitmail=mohamedwdalsir@gmail.com

#chatgpt API
OPENAI_API_KEY=""

#mytoken
token=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



#Functions
# function to insert name and email of GitHub
gtc() {
    git config --global user.name "$gituser"
    git config --global user.email "$gitmail"
    echo "Git global configuration set to Name: $gituser, Email: $gitmail"
}



#clone any repo

gcl() {
    git clone https://$token@github.com/$gituser/$1.git
    cd $1
}

gu() {
    echo "git clone https://github.com/Moealsir/$1.git"
}


#echo
e() {
     echo "$1" > "$2"
}

#append
ea() {
    echo "$1" >> "$2"
}

#git add commit push
g() {
    git pull
    git add .
    git commit -m "$*"
    git push
}


#make di and cd dir
m() {
   mkdir -v -p $1
   cd $1
}



#navigator
re() {
    if [ "$#" -eq 1 ]; then
        # Use the provided path number as an argument and change directory
        eval "$(dir_navigator.sh "$1")"
    else
        while true; do
            # Display directory history
            dir_navigator.sh

            # Prompt the user
            echo "Enter a number to change directory, 'c' to clear history, 'd' to delete, or 'q' to quit."
            read choice

            if [ "$choice" == "q" ]; then
                break
            elif [ "$choice" == "c" ]; then
                echo "" > ~/.dir_history
            elif [ "$choice" == "d" ]; then
                # Request user input for paths to delete
                echo "Enter the numbers of paths to delete (separated by space), or 'q' to quit:"
                read delete_choices

                if [ "$delete_choices" == "q" ]; then
                    break
                else
                    # Reverse ~/.dir_history in a temp file
                    tac "$DIR_HISTORY_FILE" > "$DIR_HISTORY_FILE.tmp"

                    # Delete the selected lines
                    IFS=" " read -ra delete_numbers <<< "$delete_choices"
                    delete_numbers=($(echo "${delete_numbers[@]}" | tr ' ' '\n' | sort -nr))
                    for num in "${delete_numbers[@]}"; do
                        sed -i "${num}d" "$DIR_HISTORY_FILE.tmp"
                    done

                    # Reverse the temp file again before updating ~/.dir_history
                    tac "$DIR_HISTORY_FILE.tmp" > "$DIR_HISTORY_FILE"

                    # Remove the temporary file
                    rm "$DIR_HISTORY_FILE.tmp"
                fi
            else
                # Use the choice as an argument and change directory
                eval "$(dir_navigator.sh "$choice")"
                break
            fi
        done
    fi
}


cleanup_dir_history() {
    wait

    # Read the file from the end, remove duplicates, and update the history file
    tac "$DIR_HISTORY_FILE" | awk '!seen[$0]++' | tac > "$DIR_HISTORY_FILE.tmp"
    mv "$DIR_HISTORY_FILE.tmp" "$DIR_HISTORY_FILE"
}

export DIR_HISTORY_FILE="$HOME/.dir_history"

# Append the new directory to the history file whenever 'cd' is used
cd() {
    builtin cd "$@" && echo "$PWD" >> "$DIR_HISTORY_FILE"
}


#touch files
code='code'
t() {
    if [[ "$#" -eq 1 && ("$1" == "." || "$1" == "./") ]]; then
        $code .
    else
        for file in "$@"; do
            # Check if the argument ends with .sh
            touch "$file"
            $code "$file"
            if [[ "$file" == *.sh ]]; then
                # If it ends with .sh, chmod +x to it
                chmod +x "$file"
            fi
            # Perform the normal action
            $code "$file"
        done
    fi
}

bfix() {
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get dist-upgrade
    sudo apt-get autoremove
    sudo apt-get autoclean
}

#Basic aliases
clone_repo() {
    git clone $1
    cd $1
}

sv1="ubuntu@34.207.227.27"
sv2="ubuntu@54.160.121.24"
sv3="ubuntu@52.91.120.57"

# Alias for server 1
alias sr1="sshpass ssh ubuntu@34.207.227.27 -o ServerAliveInterval=60 -o ServerAliveCountMax=240 "

# Alias for server 2
alias sr2="sshpass ssh ubuntu@54.160.121.24 -o ServerAliveInterval=60 -o ServerAliveCountMax=240 "

# Alias for server 3
alias sr3="sshpass ssh ubuntu@52.3.251.171 -o ServerAliveInterval=60 -o ServerAliveCountMax=240 "


alias cl="clone_repo"
alias bf="bfix"
alias q="python3"

# Load NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load NVM
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load NVM bash completion

# Add Console Ninja to PATH
PATH=~/.console-ninja/.bin:$PATH
alias h='history'
alias ob='code ~/.bashrc'
alias sb='source ~/.bashrc'
alias i='sudo apt-get install'
alias d='trash'
alias dd='sudo rm -rf /home/siroo/.local/share/Trash/files/*'
alias cx='chmod +x'
alias xx='chmod -x'


#go back to previous directories
alias b='cd ..'
alias bb='cd ../..'
alias b3='cd ../../../'
alias b4='cd ../../../../'
alias b5='cd ../../../../../'


#Git aliases
alias ada='git add *'
alias ad='git add'
alias gb='git branch'
alias st='git status'
alias gco='git checkout'
alias gp='git push'
alias pl='git pull'

alias s1='sshpass '

#Auto completetion for bash shell for default user:

# Check if ble.sh is installed
if [ ! -d "$HOME/ble.sh" ]; then
    # Clone the repository and build ble.sh
    sudo apt install make
    cd ~
    mkdir tmp
    cd tmp
    git clone --recursive https://github.com/akinomyoga/ble.sh.git $HOME/ble.sh
    make -C $HOME/ble.sh
    cd ..
    rm -rf tmp
fi

# Source ble.sh
source $HOME/ble.sh/out/ble.sh



export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

PATH=~/.console-ninja/.bin:$PATH



migsql() {
    # If arguments are not provided, prompt for input
    if [ -z "$1" ]; then
        read -p "Enter database user: " db_user
    else
        db_user=$1
    fi

    if [ -z "$2" ]; then
        read -p "Enter database name: " db_name
    else
        db_name=$2
    fi

    if [ -z "$3" ]; then
        read -p "Enter server username: " server_user
    else
        server_user=$3
    fi

    if [ -z "$4" ]; then
        read -p "Enter server name: " server_name
    else
        server_name=$4
    fi

    if [ -z "$5" ]; then
        read -p "Enter path to dump: " dump_path
    else
        dump_path=$5
    fi

    # Dump the database
    mysqldump -u "$db_user" -p --opt "$db_name" > "${db_name}.sql"

    # Transfer the dump to the server
    scp "${db_name}.sql" "${server_user}@${server_name}:${dump_path}"

    echo "Database dump and transfer complete."
B


sp() {
    if [ -z "$1" ]; then
        echo "Usage: sp <size-in-GB>"
        return 1
    fi

    # Check if the argument is a positive integer
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Error: The size must be a positive integer."
        return 1
    fi

    # Define the size
    local size="${1}G"

    # Create the swap file
    sudo fallocate -l "$size" /swapfile

    # Set the correct permissions
    sudo chmod 600 /swapfile

    # Make the swap file
    sudo mkswap /swapfile

    # Enable the swap file
    sudo swapon /swapfile

    # Backup the fstab file
    sudo cp /etc/fstab /etc/fstab.bak

    # Add the swap file entry to /etc/fstab for persistence
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

    # Add sysctl parameters
    echo "
vm.swappiness=10
vm.vfs_cache_pressure=50
" | sudo tee -a /etc/sysctl.conf

    # Apply the new sysctl settings
    sudo sysctl -p

    echo "Swap file created, configured, and sysctl settings updated successfully."
}
}
