#!/bin/bash
#
# Library for file system actions

# Load Generic Libraries
. ./liblog.sh

# Functions

########################
# Ensure a file/directory is owned (user and group) but the given user
# Arguments:
#   $1 - filepath
#   $2 - owner
# Returns:
#   None
#########################
owned_by() {
    local path="${1:?path is missing}"
    local owner="${2:?owner is missing}"

    chown "$owner":"$owner" "$path"
}

########################
# Ensure a directory exists and, optionally, is owned by the given user
# Arguments:
#   $1 - directory
#   $2 - owner
# Returns:
#   None
#########################
ensure_dir_exists() {
    local dir="${1:?directory is missing}"
    local owner="${2:-}"

    mkdir -p "${dir}"
    if [[ "$owner" != "" ]]; then
        owned_by "$dir" "$owner"
    fi
}

########################
# Checks whether a directory is empty or not
# Arguments:
#   $1 - directory
# Returns:
#   Boolean
#########################
is_dir_empty() {
    local dir="${1:?missing directory}"

    if [[ ! -e "$dir" ]] || [[ -z "$(ls -A "$dir")" ]]; then
        true
    else
        false
    fi
}

########################
# Configure permisions and ownership recursively
# Globals:
#   None
# Arguments:
#   $1 - paths (as a string).
# Flags:
#   -f|--file-mode - mode for directories.
#   -d|--dir-mode - mode for files.
#   -u|--user - user
#   -g|--group - group
# Returns:
#   None
#########################
configure_permissions_ownership() {
    local -r paths="${1:?paths is missing}"
    local dir_mode=""
    local file_mode=""
    local user=""
    local group=""

    # Validate arguments
    shift 1
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -f|--file-mode)
                shift
                file_mode="${1:?missing mode for directories}"
                ;;
            -d|--dir-mode)
                shift
                dir_mode="${1:?missing mode for files}"
                ;;
            -u|--user)
                shift
                user="${1:?missing user}"
                ;;
            -g|--group)
                shift
                group="${1:?missing group}"
                ;;
            *)
                echo "Invalid command line flag $1" >&2
                return 1
                ;;
        esac
        shift
    done

    read -r -a filepaths <<< "$paths"
    for p in "${filepaths[@]}"; do
        if [[ -e "$p" ]]; then
            [[ -n $dir_mode ]] && find -L "$p" -type d -exec chmod "$dir_mode" {} \;
            [[ -n $file_mode ]] && find -L "$p" -type f -exec chmod "$file_mode" {} \;
            [[ -n $user ]] && [[ -n $group ]] && chown -LR "$user":"$group" "$p"
            [[ -n $user ]] && [[ -z $group ]] && chown -LR "$user" "$p"
            [[ -z $user ]] && [[ -n $group ]] && chgrp -LR "$group" "$p"
        else
            warn "$p does not exist!!"
        fi
    done
}
