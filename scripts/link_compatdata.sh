#!/bin/bash

# Steam installs each game to a folder named with the game's title, but each
# Windows game's Wine prefix occupies a separate folder named with the game's
# numerical app ID, which can be inconvenient. Similarly, shader caches are
# organized by app ID as well. This simple Bash script creates symbolic links
# in Steam's `compatdata` and `shadercache` folders in order to identify each
# numerically named folder by the corresponding game's title.

# The games' titles are obtained from the `appmanifest_*.acf` files in the
# `steamapps` folder, of which there should be one for each installed game, so
# this works only for currently installed games, even if an uninstalled game
# has left a Wine prefix behind.

# This script operates on a few assumptions:
# * that colored output using ANSI escape sequences is supported;
# * that the user's `steamapps` folder is in the location indicated by the
#   `STEAMAPPS` variable below (and the user may edit this line if it's wrong);
# * that the `compatdata` and `shadercache` folders contain only:
#   * folders whose names are numerical app IDs of Steam games;
#   * links created by previous runs of this script.

# This script comes with no warranty of any kind. Use it at your own risk.

STEAMAPPS=~/.steam/root/steamapps
COMPATDATA=${STEAMAPPS}/compatdata
SHADERCACHE=${STEAMAPPS}/shadercache

for item in ${COMPATDATA}/* ${SHADERCACHE}/*
do
	# Ignore links.
	if [ -L "${item}" ]
	then
		continue
	fi
	# Assume anything else is a folder with an app ID name.
	number=$(basename "${item}")
	# Locate the app manifest file; if it doesn't exist, skip this item.
	manifest=${STEAMAPPS}/appmanifest_${number}.acf
	if [ ! -f "${manifest}" ]
	then
		# App ID "0" seems to have some special use; it's not a game.
		if [ ${number} -eq "0" ]
		then
			continue
		fi
		echo -e "\e[31mNo app manifest for app ID:\e[39m ${number}"
		continue
	fi
        # Get the game title from the app manifest; remove any slashes.
	title=$(grep -oP '"name"\s+"\K.+(?=")' ${manifest} | sed "s/\//-/g")
	# Use the game title as the name of a symbolic link.
	link="$(dirname "${item}")/${title}"
	# Create the link to the app ID folder if it doesn't already exist.
	if [ -L "${link}" ]
	then
		target=$(readlink "${link}")
		if [ "${target}" == "${number}" ]
		then
			echo -en "\e[33m"
		else
			echo -en "\e[31m"
		fi
		echo -e "Existing link:\e[39m '${link}' -> '${target}'"
	else
		echo -en "\e[32mCreating link:\e[39m "
		ln -sv ${number} "${link}"
	fi
done
