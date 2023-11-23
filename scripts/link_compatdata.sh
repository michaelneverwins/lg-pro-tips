#!/bin/bash

# Steam installs each game to a folder named with the game's title, but each
# Windows game's Wine prefix occupies a separate folder named with the game's
# numerical app ID, which can be inconvenient. Similarly, shader caches are
# organized by app ID as well. This simple Bash script creates symbolic links
# in Steam's `compatdata`, `shadercache`, and `userdata/*` folders in order to
# identify each numerically named folder by the corresponding game's title.
# Additionally, it creates `_compatdata`, `_shadercache`, and `_userdata` links
# in each game's install folder for easier navigation from the Steam client
# (which has an option to open a game's install folder in a file manager but no
# such options for the other locations).

# Games' titles and install folders are obtained from the `appmanifest_*.acf`
# files in the `steamapps` folder, of which there should be one for each
# installed game, so this works only for currently installed games, even if an
# uninstalled game has left a Wine prefix behind. Note also that some folders
# in `compatdata` and `shadercache` may not correspond to any app manifest,
# such as those created for non-Steam games. There may also be `compatdata` and
# `userdata` folders for non-game app IDs.

# This script operates on a few assumptions:
# * that colored output using ANSI escape sequences is supported;
# * that the user's `steamapps` folder is in the location indicated by the
#   `STEAMAPPS` variable below (and the user may edit this line if it's wrong);
# * that there is only one `userdata/*/x` for each app ID `x`, which seems like
#   a safe assumption and allows us to use "userdata" instead of user IDs in
#   the names of links from install folders to userdata folders;
# * that the `compatdata`, `shadercache`, and `userdata/*` folders contain only:
#   * folders whose names are numerical app IDs;
#   * links created by previous runs of this script.

# This script comes with no warranty of any kind. Use it at your own risk.

STEAMROOT=~/.steam/root
STEAMAPPS=${STEAMROOT}/steamapps
COMMON=${STEAMAPPS}/common
COMPATDATA=${STEAMAPPS}/compatdata
SHADERCACHE=${STEAMAPPS}/shadercache
USERDATA=${STEAMROOT}/userdata/*

for item in ${COMPATDATA}/* ${SHADERCACHE}/* ${USERDATA}/*
do
	# Ignore links.
	if [ -L "${item}" ]
	then
		continue
	fi
	# Assume anything else of interest is a folder with an app ID name.
	number=$(basename "${item}")
	if ! [[ ${number} =~ ^[0-9]+$ ]]
	then
		continue
	fi
	# Locate the app manifest file; if it doesn't exist, skip this item.
	manifest=${STEAMAPPS}/appmanifest_${number}.acf
	if [ ! -f "${manifest}" ]
	then
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
	elif [ -e "${link}" ]
	then
		echo -e "\e[31mFile or directory exists:\e[39m '${link}'"
	else
		echo -en "\e[32mCreating link:\e[39m "
		ln -sv ${number} "${link}"
	fi
	# Get the game's install folder name from the app manifest.
	installdir=$(grep -oP '"installdir"\s+"\K.+(?=")' ${manifest})
	# Create a link from the install folder if it doesn't already exist.
	if grep -Eq '.+/userdata/[^/]+/[^/]+$' <<< "${item}"
	then
		link="${COMMON}/${installdir}/_userdata"
	else
		link="${COMMON}/${installdir}/_$(basename $(dirname "${item}"))"
	fi
	if [ -L "${link}" ]
	then
		target=$(readlink "${link}")
		if [ "${target}" == "${item}" ]
		then
			echo -en "\e[33m"
		else
			echo -en "\e[31m"
		fi
		echo -e "Existing link:\e[39m '${link}' -> '${target}'"
	elif [ -e "${link}" ]
	then
		echo -e "\e[31mFile or directory exists:\e[39m '${link}'"
	else
		echo -en "\e[32mCreating link:\e[39m "
		ln -sv "${item}" "${link}"
	fi
done
