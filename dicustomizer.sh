#!/usr/bin/env bash
# Generates a Preseed file from a template with some essential customizations
# author: Carmelo C
# email: carmelo.califano@gmail.com
# history, date format ISO 8601:
#  2025-05-12: More edits
#  2024-01-10: Minor edits
#  2024-01-09: First release

# Setup
#set -Eeuo pipefail
#set -x

# Settings
VERSION="1.0"
TEMPLATENAME="preseed_cfg.tmpl"
OUTPUTFILE="preseed.cfg"
SUBNETNAME="example.org"
# source: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# ANSI colors
RED="\033[0;31m"     # red = Error
GREEN="\033[0;32m"   # green = OK
ORANGE="\033[0;33m"  # orange = Warning
NC="\033[0m"         # No Color


usage() {
    echo "Usage: ${0##*/} [command] <project_name>"
    echo "Command list:"
    echo -e "\t-h: Help"
    echo -e "\t-V: Version"
    echo -e "\t-p: Project name (destination directory)\n"
}


main() {
#    read -rp "Enter project name: " PROJECT
#    if [ -z "${PROJECT}" ]; then
#        echo "[-] Project name is mandatory"
#        exit 255
#    fi

#    echo "Project = ${PROJECT}"

    if [ ! -d "${PROJECT}" ]; then
        echo "[-] Project '${PROJECT}' not found, quitting!"
        exit 10
    fi

    if [ -f "${PROJECT}/${OUTPUTFILE}" ]; then
        echo "[-] File '${OUTPUTFILE}' is already present"
        echo "[-] Overwriting not allowed!!!"
        echo -e "[-] Terminating!!!\n"
        exit 20
    fi

    echo -n "[+] Generating '${OUTPUTFILE}' from template... "
    cp "$SCRIPT_DIR/$TEMPLATENAME" "${PROJECT}/${OUTPUTFILE}"
    echo "done!"

    read -rp "Enter hostname (e.g. testhost): " HOSTNAME
    HOSTNAME=${HOSTNAME:-testhost}
    echo -n "[+] Setting hostname... "
    sed -i "s/THISHOSTNAME/${HOSTNAME}/" "${PROJECT}/${OUTPUTFILE}"
    sed -i "s/THISSUBNET/${SUBNETNAME}/" "${PROJECT}/${OUTPUTFILE}"
    echo "done!"

    read -rp "Enter username (e.g. myuser): " USERNAME
    USERNAME=${USERNAME:-myuser}
    echo -n "[+] Setting username... "
    sed -i "s/THISUSERNAME/${USERNAME}/" "${PROJECT}/${OUTPUTFILE}"
    echo "done!"

    read -s -rp "Enter password (e.g. mypassword): " PASSWORD
    PASSWORD=${PASSWORD:-mypassword}
    echo; echo -n "[+] Setting password... "
    sed -i "s/THISPASSWORD/${PASSWORD}/" "${PROJECT}/${OUTPUTFILE}"
    echo "done!"

    read -rp "Enter Ethernet interface IP address (e.g. 192.0.2.117): " IPADDR
    IPADDR=${IPADDR:-192.0.2.117}
    echo -n "[+] Setting IP address... "
    sed -i "s/THISIPADDR/${IPADDR}/" "${PROJECT}/${OUTPUTFILE}"
    echo "done!"

    read -rp "Enter disk device name (e.g. sda [default], vda,...): " DEVNAME
    DEVNAME=${DEVNAME:-sda}
    echo -n "[+] Setting device name... "
    sed -i "s/THISDEVNAME/${DEVNAME}/" "${PROJECT}/${OUTPUTFILE}"
    echo "done!"

    echo "[+] Customization complete!"
    echo "[+] Settings written to: ${PROJECT}/${OUTPUTFILE}"
}

while getopts ":hp:V" opt; do
  case ${opt} in
    h ) # help
      usage
      exit 0
      ;;
    p ) # project/directory
      PROJECT="$OPTARG.proj"
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
