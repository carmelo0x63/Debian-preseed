#!/usr/bin/env bash
# Creates the directory structure to create a custom Debian ISO 
# Tested with:
# - Linux: OpenSSL 3.0.11
# - macOS: OpenSSL 3.1.4
# author: Carmelo C
# email: carmelo.califano@gmail.com
# history, date format ISO 8601:
#  2025-05-10: More edits
#  2024-01-09: First release

# Setup
#set -Eeuo pipefail
#set -x

# Settings
VERSION="1.0"

# ANSI colors
RED="\033[0;31m"
GREEN="\033[0;32m"
ORANGE="\033[0;33m"
NC="\033[0m"         # No Color

usage() {
    echo "Usage: ${0##*/} [command] <project_name>"
    echo "Command list:"
    echo -e "\t-h: Help"
    echo -e "\t-V: Version"
    echo -e "\t-d: Project name (destination directory)\n"
}

newDir() {
    if [ ! -d $1 ]; then
        mkdir $1
        echo -e "${GREEN}[+]${NC} NEW directory $1 created, OK"
    else
        echo -e "${ORANGE}[!]${NC} Directory $1 already exists, skipping..."
    fi
}

newFile() {
    if [ ! -f $1 ]; then
        case "$2" in
              new)     touch $1;;
        esac
        echo -e "${GREEN}[+]${NC} NEW file $1 created, mode '$2', OK"
    else
        echo -e "${ORANGE}[!]${NC} File $1 already exists, skipping..."
    fi
}

main() {
    echo -e "${GREEN}[+]${NC} Creating/updating hierarchy in directory '$DESTDIR'"
    newDir $DESTDIR

    for dirname in destination_iso source_iso workdir loopdir; do
        newDir $DESTDIR/$dirname
    done

    echo "*.iso" > $DESTDIR/.gitignore
    echo "workdir/" >> $DESTDIR/.gitignore
    echo "loopdir/" >> $DESTDIR/.gitignore

#    echo -e "${GREEN}[+]${NC} Creating $DESTDIR/iso_destination/.gitignore"
#    newFile $DESTDIR/iso_destination/.gitignore new
#    echo "*.iso" > $DESTDIR/iso_destination/.gitignore

#    echo -e "${GREEN}[+]${NC} Creating $DESTDIR/iso_source/.gitignore"
#    newFile $DESTDIR/iso_source/.gitignore new
#    echo "*.iso" > $DESTDIR/iso_source/.gitignore

#    echo -e "${GREEN}[+]${NC} Creating $DESTDIR/workdir/.gitignore"
#    newFile $DESTDIR/workdir/.gitignore new
#    echo "*.iso" > $DESTDIR/workdir/.gitignore
}

while getopts ":hd:V" opt; do
  case ${opt} in
    h ) # help
      usage
      exit 0
      ;;
    d ) # project/directory
      DESTDIR="$OPTARG.proj"
      main
      exit 0
      ;;
    V ) # Version
      echo -e "${0##*/} v. $VERSION\n"
      exit 0
      ;;
    \? )
      echo -e "${RED}[-]${NC} Invalid option: '$OPTARG'!\n"
      usage
      exit 255
      ;;
    : )
      echo -e "${RED}[-]${NC} Invalid option: '-$OPTARG' requires an argument!\n"
      usage
      exit 254
      ;;
  esac
done

shift $((OPTIND -1))

if [ "$OPTIND" -lt 2 ]; then
  usage
  exit 1
fi

