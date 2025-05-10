#!/usr/bin/env bash
# Generates a Preseed file from a template with some essential customizations
# author: Carmelo C
# email: carmelo.califano@gmail.com
# history, date format ISO 8601:
#  2025-05-10: More edits
#  2024-01-10: Minor edits
#  2024-01-09: First release

TEMPLATENAME="preseed_cfg.tmpl"
OUTPUTFILE="preseed.cfg"
#DESTDIR="$HOME/KVM"
DESTDIR="./"
SUBNETNAME="example.org"
# source: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -d "$DESTDIR" ]; then
    echo "[-] Destination directory '${DESTDIR}.cfg' is not present"
    echo -e "[-] Terminating!!!\n"
    exit 10
fi

if [ -f "$DESTDIR/${OUTPUTFILE}" ]; then
    echo "[-] File '${OUTPUTFILE}' is already present"
    echo "[-] Overwriting not allowed!!!"
    echo -e "[-] Terminating!!!\n"
    exit 20
fi

echo -n "[!] Generating '${OUTPUTFILE}' from template... "
cp "$SCRIPT_DIR/$TEMPLATENAME" "${OUTPUTFILE}"
echo "done!"

read -p "Enter hostname (e.g. testhost): " HOSTNAME
HOSTNAME=${HOSTNAME:-testhost}
echo -n "[!] Setting hostname... "
sed -i "s/THISHOSTNAME/${HOSTNAME}/" "${OUTPUTFILE}"
sed -i "s/THISSUBNET/${SUBNETNAME}/" "${OUTPUTFILE}"
echo "done!"

read -p "Enter username (e.g. myuser): " USERNAME
USERNAME=${USERNAME:-myuser}
echo -n "[!] Setting username... "
sed -i "s/THISUSERNAME/${USERNAME}/" "${OUTPUTFILE}"
echo "done!"

read -s -p "Enter password (e.g. mypassword): " PASSWORD
PASSWORD=${PASSWORD:-mypassword}
echo; echo -n "[!] Setting password... "
sed -i "s/THISPASSWORD/${PASSWORD}/" "${OUTPUTFILE}"
echo "done!"

read -p "Enter Ethernet interface IP address (e.g. 192.0.2.117): " IPADDR
IPADDR=${IPADDR:-192.0.2.117}
echo -n "[!] Setting IP address... "
sed -i "s/THISIPADDR/${IPADDR}/" "${OUTPUTFILE}"
echo "done!"

read -p "Enter disk device name (e.g. sda [default], vda,...): " DEVNAME
DEVNAME=${DEVNAME:-sda}
echo -n "[!] Setting device name... "
sed -i "s/THISDEVNAME/${DEVNAME}/" "${OUTPUTFILE}"
echo "done!"

echo "[+] Customization complete!"
echo "[+] Destination directory: ${DESTDIR}"

#echo -n "[+] Moving file into $DESTDIR... "
#mv "${OUTPUTFILE}" "${DESTDIR}"
#echo -e "OK!\n"

