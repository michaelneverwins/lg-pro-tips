#!/bin/sh

# Bottles creates desktop entries with `Categories=Application;` which causes
# games to show up under "Other" (instead of "Games") in Linux Mint's menu.
# Assume all Bottles shortcuts are games, and replace `Categories=Application;`
# with `Categories=Game;` in each of them.

# This script comes with no warranty of any kind. Use it at your own risk.

# Note also that this script may break or become useless depending on how the
# following issue is resolved:
#   https://github.com/bottlesdevs/Bottles/issues/2578

BAD='^Categories=Application;$'
GOOD='Categories=Game;'
for entry in ~/.local/share/applications/*.desktop
do
	if grep -q '^Exec=flatpak run --command=bottles-cli' "${entry}"
	then
		if grep -q ${BAD} "${entry}"
		then
			sed s/${BAD}/${GOOD}/ -i "${entry}"
			echo "Fixed: ${entry}"
		fi
	fi
done
