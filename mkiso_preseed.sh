#!/usr/bin/env bash
# Creates a customized ISO file based on preseed.cfg file
# author: Carmelo C
# email: carmelo.califano@gmail.com
# history, date format ISO 8601:
#  2025-05-12: First release

# Source info:
# - https://wiki.debian.org/DebianInstaller/Preseed
# - https://wiki.debian.org/DebianInstaller/Preseed/EditIso

# Setup
#set -Eeuo pipefail
#set -x

# Settings
VERSION="1.0"

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
    # Check whether the script is run as root or with sudo
    if [ "$EUID" -ne 0 ]; then
        echo "[-] This script must be run as root or with sudo"
        exit 255
    fi

#    read -rp "Enter project name: " PROJECT
#    if [ -z "${PROJECT}" ]; then
#        echo "[-] Project name is mandatory"
#        exit 255
#    fi

    if [ ! -d "${PROJECT}.proj" ]; then
        echo "[-] Project '${PROJECT}.proj' not found, quitting!"
        exit 10
    fi


    # Setting directory names
    read -rp "Enter OS version (e.g. 12.10.0): " DEBVER
    DEBVER=${DEBVER:-12.10.0}

    read -rp "Enter architecture (e.g. amd64): " DEBARCH
    DEBARCH=${DEBARCH:-amd64}

    RAW_DEBIAN_ISO="${PROJECT}.proj/source_iso/debian-${DEBVER}-${DEBARCH}-netinst.iso"

    WORKDIR="$PROJECT.proj/workdir"
    LOOPDIR="$PROJECT.proj/loopdir"
    ISODIR="$WORKDIR/isodir"

    PRESEED_FILE="${PROJECT}.proj/preseed.cfg"
    PRESEED_ISO="${PROJECT}.proj/destination_iso/debian-$DEBVER-$DEBARCH-netinst-preseed.iso"

    echo "$WORKDIR"
    echo "$LOOPDIR"
    echo "$ISODIR"
    echo "$RAW_DEBIAN_ISO"
    echo "$PRESEED_FILE"
    echo "$PRESEED_ISO"

    # Clean-up `WORKDIR`
    if [ -d "${WORKDIR}" ]; then
#        chmod +w -R $WORKDIR
#        sudo rm -rf "${WORKDIR}"
        rm -rf "${WORKDIR}"
    fi

    # Mount source ISO
    echo "[+] Mounting '$RAW_DEBIAN_ISO' onto '$LOOPDIR'"
#    sudo mount "${RAW_DEBIAN_ISO}" "{$LOOPDIR}"
    mount "${RAW_DEBIAN_ISO}" "{$LOOPDIR}"

    # Copy image
    mkdir -p "${ISODIR}"
    cp -rT "${LOOPDIR}" "${ISODIR}"
    chmod +w -R "${WORKDIR}"
#    sudo umount "${LOOPDIR}"
    umount "${LOOPDIR}"

    # Patch initrd with the modified preseed file
    gunzip "${ISODIR}"/install.amd/initrd.gz
    echo "${PRESEED_FILE}" | cpio -H newc -o -A -F "${ISODIR}"/install.amd/initrd &> /dev/null
    gzip "${ISODIR}"/install.amd/initrd

    # Fix md5sum
    PREVIOUS_WORKING_DIR=$(pwd)
    cd "${ISODIR}"
    find . -type f -exec md5sum "{}" \; > md5sum.txt
    cd "${PREVIOUS_WORKING_DIR}"

    # Fix grub.cfg
    #sudo sed -i "1s/^/set timeout=3\nset default=1\n\n/" "${ISODIR}"/boot/grub/grub.cfg

    # Fix isolinux.cfg
#    sudo sed -i "s/default vesamenu.c32/default auto/" "${ISODIR}"/isolinux/isolinux.cfg
    sed -i "s/default vesamenu.c32/default auto/" "${ISODIR}"/isolinux/isolinux.cfg

    # Create ISO
    # IMPORTANT: the arguments passed to the -b and -c flags should be RELATIVE paths to the last argument
    genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -input-charset utf-8 \
            -o "$PRESEED_ISO" "$ISODIR" &> /dev/null

    echo "[+] Preseed config '$PRESEED_FILE' has been successfully merged into image '$PRESEED_ISO'"
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
