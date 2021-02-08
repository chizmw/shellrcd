#!/bin/sh
# vim: filetype=sh:et:ts=4:sts=4:sw=4:si:ai
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   curl -fsSL -o ~/install-shellrcd.sh https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh
#   $EDITOR ~/install-shellrcd.sh
#   sh -c ~/install-shellrcd.sh

set -eu

SHELLRCDIR=~/.shellrc.d

# stolen from https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
unset command_exists
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# stolen from https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
unset setup_color
setup_color() {
    # Only use colors if connected to a terminal
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        RESET=""
    fi
}

unset already_installed
already_installed() {
    _rcfile="${1:?Missing Argument}"
    if [ ! -e "${_rcfile}" ]; then
        false
    else
        # https://unix.stackexchange.com/questions/330660/prevent-grep-from-exiting-in-case-of-nomatch/403707#comment581721_330662
        count=$(grep -c '^## added by shellrcd ##' "${_rcfile}" || :)
        [ "$count" -gt 0 ]
    fi
}

unset write_new_file
write_new_file() {
    rcfile=${1:?Missing rcfile}
    shell=${2:?Missing shell}

    echo "#!${shell}" > "${rcfile}"
    append_block "${rcfile}"
}

unset append_block
append_block() {
    cat >> "${1:?Missing rcfile argument}" <<EOF

## added by shellrcd ##
if [ -f ~/.shellrc.d/source-relevant-files -a -x ~/.shellrc.d/source-relevant-files ]; then
    source ~/.shellrc.d/source-relevant-files
fi
## end of shellrcd block ##

EOF
}

unset append_block_if_missing
append_block_if_missing() {
    rcfile=${1:?Missing rcfile}
    shell=${2:?Missing shell}

    if [ -f "${rcfile}" ] || [ -h "${rcfile}" ]; then
        if already_installed "${rcfile}"; then
            echo "[${shell}] shellrcd block already added to ${rcfile}. Nothing to do."
        else
            echo "[${shell}] Adding shellrcd block to ${YELLOW}${rcfile}${RESET}..."
            append_block "${rcfile}"
        fi
    else
        echo "[${shell}] trying to append to missing file: ${RED}${rcfile}${RESET}"
    fi
}

unset append_or_create
append_or_create() {
    rcfile=${1:?Missing rcfile}
    shell=${2:?Missing shell}

    # check for broken links
    if [ -L "${rcfile}" ] && [ ! -f "${rcfile}" ]; then
        echo    "[${shell}] ${RED}${rcfile} seems to be a broken symlink.${RESET} Moving..."
        mv -v "${rcfile}" "${rcfile}.broken"
    fi

    if [ -f "${rcfile}" ] || [ -h "${rcfile}" ]; then
        append_block_if_missing "${rcfile}" "${shell}"
    else
        # nothing in the home directory
        # if we have "dotfiles/dot-zshrc" link straight to it
        if [ -f "${SHELLRCDIR}/dotfiles/dot-${shell}rc" ]; then
            echo "[${shell}] Linking ${SHELLRCDIR}/dotfiles/dot-${shell}rc to ${YELLOW}${rcfile}${RESET}"
            ln -s "${SHELLRCDIR}/dotfiles/dot-${shell}rc" "${rcfile}"
            append_block_if_missing "${rcfile}" "${shell}"
        else
            echo "[${shell}] Creating ${YELLOW}${rcfile}${RESET} and adding shellrcd block..."
            write_new_file "$rcfile" "$(which "${shell}")"
        fi
    fi
}

unset setup_zshrc
setup_zshrc() {
    rcfile=~/.zshrc
    shell=zsh

    echo "[${shell}] ${YELLOW}Looking for an existing zsh config...${RESET}"

    append_or_create "${rcfile}" "${shell}"
}

unset setup_bashrc
setup_bashrc() {
    unset rcfile
    shell=bash

    echo "[${shell}] ${YELLOW}Looking for an existing bash config...${RESET}"

    # we should use .bash_profile if we're being "proper" on a mac
    # but for the rest of the world, .bashrc seems to be acceptable
    # https://serverfault.com/a/376264
    case "$(uname)" in
        Darwin*)
            echo "[${shell}] ${RED}MacOS${RESET} detected. Using ${YELLOW}.bash_profile${RESET}."
            rcfile=~/.bash_profile
            ;;
        *)
            echo "[${shell}] ${RED}Non-MacOS${RESET} detected. Using ${YELLOW}.bashrc${RESET}."
            rcfile=~/.bashrc
            ;;
    esac

    append_or_create "${rcfile}" "${shell}"
}

unset setup_shellrcd_directory
setup_shellrcd_directory() {
    if [ -e "${SHELLRCDIR}" ]; then
        echo "[shellrcd] ${SHELLRCDIR} already exists. Leaving unchanged."
    else
        echo "[shellrcd] ${YELLOW}${SHELLRCDIR} is not found${RESET}. Downloading..."
        git clone --origin shellrcd \
            --quiet \
            --branch=master git://github.com/chiselwright/shellrcd.git \
            "${SHELLRCDIR}"
        echo "[shellrcd] ...done"
    fi
}

unset setup_shellrcd_extra
setup_shellrcd_extra() {
    # set values with empty defaults
    extra_repo=${SHELLRCD_EXTRA_REPO:-}
    extra_branch=${SHELLRCD_EXTRA_BRANCH:-}

    if [ -n "${extra_repo}" ];then
        # we have a desired repo, do we know the branch?
        if [ -z "${extra_branch}" ]; then
            echo "[shellrcd] ${RED}SHELLRCD_EXTRA_REPO set, but missing a value for SHELLRCD_EXTRA_BRANCH${RESET}"
            exit
        fi

        echo "[shellrcd] Configuring ${YELLOW}${extra_branch}${RESET} from ${YELLOW}${extra_repo}${RESET}"
        # do what we need to so it's set up
        git -C "${SHELLRCDIR}" remote add origin "${extra_repo}"
        git -C "${SHELLRCDIR}" remote update origin
        git -C "${SHELLRCDIR}" checkout -t "origin/${extra_branch}"
        # this just makes the history "look sensible" if you examine it in branch
        git -C "${SHELLRCDIR}" rebase master
    fi
}

unset setup_shellrcd_submodules
setup_shellrcd_submodules() {
    # we might not have any submodules, but it would be nice to check
    _count=$(git -C "${SHELLRCDIR}" submodule |wc -l)
    if [ "${_count}" -gt 0 ]; then
        echo "[shellrcd] Initialising submodules…"
        git -C "${SHELLRCDIR}" submodule init
        git -C "${SHELLRCDIR}" submodule update --recursive
    fi
}

unset show_welcome_message
show_welcome_message() {
    printf '%s' "$GREEN"
    cat <<"EOF"
           _             _    _                    _
          ( )           (_ ) (_ )                 ( )
      ___ | |__     __   | |  | |  _ __   ___    _| |
    /',__)|  _ `\ /'__`\ | |  | | ( '__)/'___) /'_` |
    \__, \| | | |(  ___/ | |  | | | |  ( (___ ( (_| |
    (____/(_) (_)`\____)(___)(___)(_)  `\____)`\__,_)
                                ....is now installed!
EOF

    cat <<EOF

    Please look over ${rcfile} for any glaring errors.

    Check which scripts are active with:
        sh ${SHELLRCDIR}/tools/list-active.sh

    Once happy, open a new shell or:
        source ${rcfile}
EOF
    printf '%s' "$RESET"
}

unset install_updater
install_updater() {
    if [ -d ~/bin ]; then
        echo "[shellrcd] ${YELLOW}Found $HOME/bin${RESET}; installing shellrcd-update"
        # probably shouldn't do anything if it's already there
        if [ -f "$HOME/bin/shellrcd-update" ]; then
            echo "[shellrcd] ${RED}$HOME/bin/shellrcd-update${RESET} already exists but is not a symbolic link"
            echo "[shellrcd] … consider removing it and running this script again"
        elif [ -L "$HOME/bin/shellrcd-update" ]; then
            echo "[shellrcd] ${YELLOW}$HOME/bin/shellrcd-update already exists${RESET}, leaving untouched"
        else
            ln -s "${SHELLRCDIR}/tools/shellrcd-update" "$HOME/bin/shellrcd-update"
        fi
    fi
}

unset shellrcd_main
shellrcd_main() {
    setup_color

    setup_shellrcd_directory
    setup_shellrcd_extra
    setup_shellrcd_submodules

    if ! command_exists zsh; then
        echo "${YELLOW}zsh is not installed.${RESET} Skipping ${GREEN}zsh${RESET} setup."
    else
        setup_zshrc
    fi

    if ! command_exists bash; then
        echo "${YELLOW}bash is not installed.${RESET} Skipping ${GREEN}bash${RESET} setup."
    else
        setup_bashrc
    fi

    install_updater

    show_welcome_message
}

shellrcd_main "$@"
