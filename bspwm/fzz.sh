#!/usr/bin/env bash

set -euo pipefail

trap 'echo -e "\n${RED}Aborted by user.${NC}"; exit 130' SIGINT

BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

check_deps() {
    local missing=()
    for dep in fzf bat git pacman systemctl; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}${BOLD}Missing Dependencies!${NC}"
        echo "Please install the following packages:"
        echo -e "${YELLOW}sudo pacman -S ${missing[*]}${NC}"
        exit 1
    fi
}

find_file() {
    local file
    file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
               --header "File Explorer | ENTER to open in Vim | ESC to cancel" \
               --height 80% --layout=reverse --border || true)

    if [[ -n "$file" ]]; then
        vim "$file"
    fi
}

kill_proc() {
    local pids
    pids=$(ps -ef | sed 1d | fzf -m \
        --header "Process Manager | TAB to multi-select | ENTER to kill" \
        --height 60% --layout=reverse --border || true)

    if [[ -n "$pids" ]]; then
        echo "$pids" | awk '{print $2}' | xargs -r kill -9
        echo -e "${GREEN}Processes terminated.${NC}"
    fi
}

git_branch() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo -e "${RED}Error:${NC} Not inside a Git repository."
        exit 1
    fi

    local branch
    branch=$(git branch -a | grep -v 'HEAD' | \
             fzf --header "Git Branches | ENTER to checkout" \
                 --height 40% --layout=reverse --border || true)

    if [[ -n "$branch" ]]; then
        local clean_branch
        clean_branch=$(echo "$branch" | sed 's/.* //;s/remotes\/origin\///')
        git checkout "$clean_branch"
    fi
}

system_health() {
    echo -e "\n${CYAN}${BOLD}=== System Health Report ===${NC}\n"

    # 1. Failed Systemd Services
    echo -e "${YELLOW}>> Checking Systemd Services...${NC}"
    local failed_services
    failed_services=$(systemctl --failed --no-pager --plain | grep "loaded")
    if [[ -z "$failed_services" ]]; then
        echo -e "${GREEN}No failed services.${NC}"
    else
        echo -e "${RED}$failed_services${NC}"
    fi
    echo ""

    echo -e "${YELLOW}>> Checking Orphaned Packages...${NC}"
    local orphans
    orphans=$(pacman -Qdtq || true)
    if [[ -z "$orphans" ]]; then
        echo -e "${GREEN}No orphaned packages found.${NC}"
    else
        echo -e "${RED}Orphans found:${NC}"
        echo "$orphans"
        echo -e "To remove them, run: ${BOLD}sudo pacman -Rns \$(pacman -Qdtq)${NC}"
    fi
    echo ""
}

activate_venv() {
    local search_dir="${1:-.}"
    echo -e "${CYAN}Searching for Python virtual environments in $search_dir...${NC}"

    local venv_path
    venv_path=$(find "$search_dir" -maxdepth 4 -type f -name "activate" | grep "bin/activate" | \
                fzf --header "Select VirtualEnv to Activate" \
                    --height 40% --layout=reverse --border || true)

    if [[ -n "$venv_path" ]]; then
        echo -e "\n${GREEN}Virtual Environment Found!${NC}"
        echo -e "Because scripts run in a subshell, to activate this environment in your current terminal, run:\n"
        echo -e "${BOLD}source \"$venv_path\"${NC}\n"
    fi
}

show_help() {
    echo -e "${BLUE}${BOLD}SYSOP - System Operator CLI${NC}"
    echo "Usage: sysop [command]"
    echo ""
    echo "Commands:"
    echo -e "  ${BOLD}-f, --file${NC}      Search and edit files with preview"
    echo -e "  ${BOLD}-k, --kill${NC}      Interactive task manager and process killer"
    echo -e "  ${BOLD}-g, --git${NC}       Switch branches in the current Git repo"
    echo -e "  ${BOLD}-p, --python${NC}    Find and output activation string for local venvs"
    echo -e "  ${BOLD}-s, --status${NC}    Run a system health check (Services & Orphans)"
    echo -e "  ${BOLD}-h, --help${NC}      Show this help menu"
    echo ""
}

main() {
    check_deps

    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file)   find_file; shift ;;
            -k|--kill)   kill_proc; shift ;;
            -g|--git)    git_branch; shift ;;
            -p|--python) activate_venv "."; shift ;;
            -s|--status) system_health; shift ;;
            -h|--help)   show_help; shift ;;
            *)           echo -e "${RED}Unknown option: $1${NC}"; show_help; exit 1 ;;
        esac
    done
}

main "$@"
