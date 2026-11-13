# --- System & History ---
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
shopt -s histappend
shopt -s checkwinsize

# --- Greyscale Palette (RGB) ---
C_BG="30;30;46"       # Dark Charcoal
C_WHITE="205;214;244" # Soft White
C_SILVER="166;173;200" # Muted Silver
C_GREY="108;112;134"  # Medium Grey
C_DARK="17;17;27"     # Deep Black

# --- Simple Professional Prompt Engine ---
__build_prompt() {
    local EXIT="$?"

    # 1. Status Dot Indicator (Turns Grey on error, White on success)
    local DOT_COLOR=$C_WHITE
    [[ $EXIT -ne 0 ]] && DOT_COLOR=$C_GREY
    local S1="\[\e[38;2;${DOT_COLOR}m\] ●\[\e[0m\]"

    # 2. Minimal User Info
    local S2=" \[\e[38;2;${C_SILVER}m\]ARCHBTW\[\e[0m\]"

    # 3. Directory with Subtle Contrast Slashes
    local RAW_DIR="\w"
    local COLORED_DIR="${RAW_DIR//\//\\[\e[38;2;${C_GREY}m\\]/\\[\e[38;2;${C_WHITE}m\\]}"
    local S3=" \[\e[38;2;${C_WHITE}m\]${COLORED_DIR}\[\e[0m\]"

    # 4. Git Integration (Clean inline text)
    local S4=""
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local BRANCH=$(git branch --show-current)
        S4=" \[\e[38;2;${C_GREY}m\](git:${BRANCH})\[\e[0m\]"
    fi

    # 5. Clean execution pointer
    local POINTER=" \[\e[38;2;${C_SILVER}m\]▶\[\e[0m\] "


    # Assemble simple line
    PS1="${S1}${S2}${S3}${S4}${POINTER}"
}

PROMPT_COMMAND=__build_prompt


# PATH

export PATH="$PATH:$HOME/.local/bin"

# Alias

alias ..='cd ..'
alias ...='cd ../..'

alias ls='ls --color=auto --group-directories-first --classify'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias grep='grep --color=auto'

alias bspconf='nano ~/.config/bspwm/bspwmrc'
alias sxhkdconf='nano ~/.config/sxhkd/sxhkdrc'
alias polyconf='nano ~/.config/polybar/config.ini'

alias sxhkd-reload='pkill -USR1 -x sxhkd'
alias bspwm-reload='bspc wm -r'

alias nekowalls='bash ~/.config/bspwm/nekowall.sh'
alias livewallon='nice -n 19 xwinwrap -ov -ni -g 1920x1080 -- mpv --wid=%WID --loop --no-audio --hwdec=vaapi --vo=gpu --gpu-api=opengl --profile=fast --vd-lavc-fast --vd-lavc-threads=1 --cache=no --demuxer-readahead-secs=0 --demuxer-max-bytes=1M --vd-lavc-dr=yes --dither=no --correct-downscaling=no --scale=bilinear --hdr-compute-peak=no --video-sync=display-resample --framedrop=vo --terminal=no --ytdl=no --msg-level=all=no "$HOME/Videos/livewall/1.mp4"'

alias musicctlon='cd "$HOME/MPP" && bash nekoplay.sh && cd'
alias fzz='bash ~/.config/bspwm/fzz.sh'
alias fan='bash ~/.config/bspwm/fan.sh'


alias fetch='neofetch --ascii_distro gentoo'

alias vidrec='gpu-screen-recorder -w screen -f 60 -k h264 -q medium -a "$(pactl get-default-sink).monitor" -ac opus -o "$HOME/Videos/game_$(date +%Y-%m-%d_%H-%M-%S).mkv"'

#######################################################
# GENERAL ALIAS'S
#######################################################
# To temporarily bypass an alias, we preceed the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Edit this .bashrc file
alias ebrc='edit ~/.bashrc'

# Show help for this .bashrc file
alias hlp='less ~/.bashrc_help'

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -iv'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias apt-get='sudo apt-get'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'
alias vi='vim'
alias svi='sudo vi'
alias vis='vim "+set si"'

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Remove a directory and all files
alias rmd='/bin/rm  --recursive --force --verbose '

# Alias's for multiple directory listing commands
alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh' # sort by extension
alias lk='ls -lSrh' # sort by size
alias lc='ls -lcrh' # sort by change time
alias lu='ls -lurh' # sort by access time
alias lr='ls -lRh' # recursive ls
alias lt='ls -ltrh' # sort by date
alias lm='ls -alh |more' # pipe through 'more'
alias lw='ls -xAh' # wide listing format
alias ll='ls -Fls' # long listing format
alias labc='ls -lap' #alphabetical sort
alias lf="ls -l | egrep -v '^d'" # files only
alias ldir="ls -l | egrep '^d'" # directories only

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search command line history
alias h="history | grep "

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show current network connections to the server
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# SHA1
alias sha1='openssl sha1'
alias recon='gpu-screen-recorder   -w screen   -f 60   -a default_output   -o ~/Videos/Recordings/rice-test.mp4'
