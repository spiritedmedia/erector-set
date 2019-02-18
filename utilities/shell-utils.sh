#!/bin/bash

# Header logging
e_header() {
    printf "\n$(tput setaf 7)%s$(tput sgr0)\n" "$@"
}

# Success logging
e_success() {
    printf "$(tput setaf 64)✓ %s$(tput sgr0)\n\n" "$@"
}

# Error logging
e_error() {
    printf "$(tput setaf 1)x %s$(tput sgr0)\n\n" "$@"
}

# Warning logging
e_warning() {
    printf "$(tput setaf 136)! %s$(tput sgr0)\n\n" "$@"
}

# Ask for confirmation before proceeding
seek_confirmation() {
    printf "\n"
    e_warning "$@"
    printf "Continue? (y/n) " && read -rn 1
    printf "\n"
}

# Test whether the result of an 'ask' is a confirmation
is_confirmed() {
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      return 0
    fi
    return 1
}

# Symlink a file to a destination and display a nice message
link_files() {
  ln -sf "$1" "$2"
  e_success "linked $1 to $2"
}

# Test whether a command exists
function command_exists() {
    if [ "$(type -P "$1")" ]; then
      return 0
    fi
    return 1
}
