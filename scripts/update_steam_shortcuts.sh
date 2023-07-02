#!/bin/bash

# When Steam creates "desktop entry" files as shortcuts to games, they always
# look something like this:

#   [Desktop Entry]
#   Name=<GAME_TITLE>
#   Comment=Play this game on Steam
#   Exec=steam steam://rungameid/<APP_ID>
#   Icon=steam_icon_<APP_ID>
#   Terminal=false
#   Type=Application
#   Categories=Game;

# The "Comment" field is always the same. This Bash script updates each Steam
# game shortcut's "Comment" field based on the contents of the library cache.
# (Each game's JSON file in the library cache may contain a "strSnippet" field
# providing a short description of the game. If no snippet is found for a given
# game, you may need to view the game in your library in order to populate the
# cache. Some games may simply not have one, particularly games which have been
# de-listed from the Steam store.)

# This script operates on a few assumptions:
# * that colored output using ANSI escape sequences is supported;
# * that the user's Steam game shortcuts and library caches are, respectively,
#   in the locations indicated by the `SHORTCUT_DIRS` and `LIBRARY_CACHE_DIRS`
#   variables below (and the user may edit these lines if they're wrong);
# * that every Steam game shortcut contains a line starting with
#     Exec=steam steam://rungameid/
#   and continuing with a numerical app ID;
# * that every Steam game shortcut contains a "Comment" field.

# This script comes with no warranty of any kind. Use it at your own risk.

SHORTCUT_DIRS=(
	~/.local/share/applications
	~/Desktop
)
LIBRARY_CACHE_DIRS=(
	~/.steam/root/userdata/*/config/librarycache
)

new_only=true
while getopts 'ah' opt
do
	case "${opt}" in
		a)
			new_only=false
			;;
		h)
			echo "Usage: $0 [-a]"
			echo 'Options:'
			echo -e '\t-a\tUpdate all shortcuts (not just those with default comment)'
			exit 0
			;;
	esac
done

for shortcut_dir in "${SHORTCUT_DIRS[@]}"
do
	for shortcut in "${shortcut_dir}"/*.desktop
	do
		if ${new_only} && ! grep -q 'Comment=Play this game on Steam' "${shortcut}"
		then
			continue
		fi
		app_id=$(grep -m 1 -oP 'Exec=steam steam://rungameid/\K\d+' "${shortcut}")
		if [ -z ${app_id} ]
		then
			continue
		fi
		title=$(grep -m 1 -oP 'Name=\K.+' "${shortcut}")
		for cache_dir in ${LIBRARY_CACHE_DIRS[@]}
		do
			cache_file=${cache_dir}/${app_id}.json
			if [ ! -f "${cache_file}" ]
			then
				continue
			fi
			comment=$(grep -oP '"strSnippet":"\K.+?[^\\](?=")' "${cache_file}" | sed s/'\\"'/'"'/g)
			if [ -z "${comment}" ]
			then
				continue
			fi
			sed s/'Comment=.*'/"Comment=$(sed s/'[\/&]'/'\\&'/g <<< ${comment})"/g -i "${shortcut}"
			echo -e "\e[32mUpdated shortcut for ${title} (${app_id}) in '${shortcut_dir}'\e[39m"
			continue 2
		done
		echo -e "\e[33mNo snippet found in library cache for ${title} (${app_id})\e[39m"
	done
done
