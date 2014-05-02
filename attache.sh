#!/bin/bash

# Currently, this really doesn't do a whole lot. Eventually it will
# help you manage your dotfiles with a git repository.

# The main feature of attache is that it facilitates the good-idea of
# not keeping your dotfiles git repo directly in your home dir.
# Instead, it stores it in the DEFAULT_ATTACHE_DIR, and then symlinks
# all of the files and directories from there into your home
# directory.

PROGNAME=$(basename $0)

DEFAULT_ATTACHE_DIR=~/.home

attache_add_file() {
    TEMP=$(getopt -o 'h' -l 'help' -n "$PROGNAME $subcommand" -- "$@")

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

    eval set -- "$TEMP"

    while true; do
        case "$1" in
            -- ) shift; break ;;
        esac
    done

    ATTACHE_FILE=${1#$DEFAULT_ATTACHE_DIR}
    [ -f $ATTACHE_FILE ] || echo "File $1 does not exist in $DEFAULT_ATTACHE_DIR" ; exit 1

    git add -vf $ATTACHE_FILE
}

sub_help() {
    echo "Usage: $PROGNAME <subcommand> [options]\n"
    echo "Subcommands:"
    echo "    status  Display the status of your attache"
    echo "    import  Import a file into your attache"
    echo ""
    echo "For help with each subcommand run:"
    echo "$PROGNAME <subcommand> -h|--help"
    echo ""
}

sub_status() {
    TEMP=$(getopt -o 'h' -l 'help' -n "$PROGNAME $subcommand" -- "$@")

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

    eval set -- "$TEMP"

    while true; do
        case "$1" in
            -h | --help ) echo "Usage: $PROGNAME $subcommand\n";
                          echo "Display the git status of your attache";
                          shift; exit ;;
            -- ) shift; break ;;
        esac
    done

    pushd $DEFAULT_ATTACHE_DIR
    git status
    popd
}

sub_import() {
    if [ -f $1 ]; then
        OLDFILE=$1
        NEWFILE=$DEFAULT_ATTACHE_DIR/${OLDFILE#~/}

        [ -f $NEWFILE ] && echo "$OLDFILE is already in your attache!"; exit 1

        mkdir -vp $(basename $NEWFILE)
        mv -vn $OLDFILE $NEWFILE
        ln -vs $NEWFILE $OLDFILE
        attache_add_file $NEWFILE

    elif [ -d $0 ]; then
        echo "Nothing yet"
    fi
}

# Keep this snippet for use with subcommands

# TEMP=$(getopt -o '' -n $(basename $0) -- "$@")

# if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# eval set -- "$TEMP"

# while true; do
#     case "$1" in
#         -- ) shift; break ;;
#     esac
# done

subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        shift
        sub_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$PROGNAME --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac
