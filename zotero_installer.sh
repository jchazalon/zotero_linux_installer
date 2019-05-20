#!/bin/bash
#
# Installer for Zotero standalone on Linux platforms.
# Modified fork from <https://github.com/smathot/zotero_installer> to
# avoid automatic download from the official website.
# Instead, the user can download and install the file he wants easily.
# I found this solution a bit more stable along Zotero releases.
#
# As previous work was released under the GPL v2 licence, I use the same
# licence, while I am not really sure it makes really sense in my country...
# So, make sure what this script does is right for you before running it.
# And then do whatever you want with it.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# If your were not provide a copy of the GNU General Public License along
# with this file, you can obtain it at <http://www.gnu.org/licenses/>.

# USAGE :
# $ sudo /path/to/this/script /path/to/zotero-archive-from-official-website.tar.bz2

# Tested for Zotero 4.0.x up to x = 20
#            Zotero 5.0.x up to x = 66

DEST_FOLDER=zotero
EXEC=zotero
ZOTERO_ARCHIVE=$1

DEST="/opt"
MENU_PATH="/usr/share/applications/zotero.desktop"
MENU_DIR="/usr/share/applications"

DEBUG_MSG_ACTIVE=true

error_exit() {
	for arg in "$@"; do
		echo ">>> $arg"
	done
	echo ">>> Aborting installation, sorry!"
	exit 1
}

action_start() {
	if [ "$DEBUG_MSG_ACTIVE" ]; then
		echo -n "$1..."
	fi
}

action_end() {
	if [ "$DEBUG_MSG_ACTIVE" ]; then
		if [ -z "$1" ]; then
			echo " done."
		else
			echo " done ($1)."
		fi
	fi
}

debug_msg () {
	if [ "$DEBUG_MSG_ACTIVE" ]; then
		for arg in "$@"; do
			echo "$arg"
		done
	fi
}

# Does the archive file given as parameter exist?
if [ ! -f "$ZOTERO_ARCHIVE" ]; then
	error_exit "Missing argument (Zotero achive)" "Syntax: $0 PATH_TO_ZOTERO_ARCHIVE" "Zotero archive is the *.tar.bz2 file downloaded from the official website."
fi

if [ -d $DEST/$DEST_FOLDER ]; then
	echo ">>> The destination folder ($DEST/$DEST_FOLDER) exists. Do you want to remove it?"
	echo ">>> y/n (default=n)"
	read INPUT
	if [ "$INPUT" = "y" ]; then
		echo ">>> Removing old Zotero installation"
		action_start "Removing $DEST/$DEST_FOLDER"
		rm -Rf $DEST/$DEST_FOLDER
		action_end
		if [ $? -ne 0 ]; then
			error_exit "Failed to remove old Zotero installation" "This script should be run as root or with sudo."
		fi
	else
		echo ">>> Aborting installation (user cancelled)."
		exit 0
	fi
fi

# Create a tmp dir for extraction, and anticipate its removal at the end of the script
tdir=
cleanup() {
    test -n "$tdir" && test -d "$tdir" && rm -rf "$tdir" && debug_msg "Temp dir \"$tdir\" automatically removed."
}
action_start "Creating tmp dir (will remove it later)"
tdir="$(mktemp -d)"
if [ $? -ne 0 ]; then
	error_exit "Failed to create temp dir for extraction."
fi
action_end "created \"$tdir\""

action_start "Setting up traps"
trap cleanup EXIT
trap 'cleanup; exit 127' INT TERM
action_end

# Decompress archive in tmp dir
action_start "Extracting program files from \"$ZOTERO_ARCHIVE\" to temp dir"
tar -xaf $ZOTERO_ARCHIVE -C $tdir
if [ $? -ne 0 ]; then
	error_exit "Failed to extract ${ZOTERO_ARCHIVE}."
fi
action_end

# Get the name of the base directory of the extracted files
action_start "Getting program files base dir"
zbasedir=$(tar -tf $ZOTERO_ARCHIVE | sort | head -n 1)
zbasedir=${zbasedir%/}
if [ -z "$zbasedir" -o ! -d "$tdir/$zbasedir" ]; then
	error_exit "Failed to identify program files base directory."
fi
action_end

# Moving files to the final installation dir
action_start "Moving \"$tdir/$zbasedir\" to \"$DEST/$DEST_FOLDER\""
mv "$tdir/$zbasedir" "$DEST/$DEST_FOLDER"
if [ $? -ne 0 ]; then
	error_exit "Failed to move Zotero to \"$DEST/$DEST_FOLDER\"" "This script should be run as root or with sudo."
fi
action_end

# Create menu entries
# Removed from original script (what was it for?)
# if [ -f $MENU_DIR ]; then
# 	echo ">>> Creating $MENU_DIR"
# 	mkdir $MENU_DIR
# fi

action_start "Creating menu entry"
echo "[Desktop Entry]
Name=Zotero
Comment=Open-source reference manager (standalone version)
Exec=$DEST/$DEST_FOLDER/zotero
Icon=accessories-dictionary
Type=Application
StartupNotify=true" > $MENU_PATH
if [ $? -ne 0 ]; then
	error_exit "Failed to create menu entry." "This script should be run as root or with sudo."
fi
action_end

echo "Installation complete under \"$DEST/$DEST_FOLDER\"."
echo "You may remove $ZOTERO_ARCHIVE now (not required any longer)."
