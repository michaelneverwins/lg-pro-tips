#!/bin/bash

# This is the script I use to provide an interface for launching one of several
# games from a single desktop/menu shortcut. Usage is as follows:
USAGE="$0 BASE_TITLE BASE_ARGS 1ST_TITLE 1ST_ARGS 2ND_TITLE 2ND_ARGS ..."

# The typical use case is to make one shortcut, instead of multiple, for a game
# which has expansion packs or for a series of games that aren't worth multiple
# shortcuts' worth of desktop real estate. Remember to set the desktop entry's
# `Terminal` field to `true` unless explicitly invoking a terminal program to
# run the script.

# The script will display the base title, present the other titles as options,
# prompt the user for numerical input, and run the command defined by the base
# args and selected additional args.

# For example one may use the script as a launcher for Final DOOM as follows:
#     multilaunch.sh 'Final DOOM' 'gzdoom -iwad' 'TNT: Evilution' 'tnt.wad -file tnt31.wad' 'The Plutonia Experiment' 'plutonia.wad'

# Any set of args may be an empty string ('') if there is nothing to put there.
# For example, there may be no additional args for the first option if it
# represents default mode of running some game:
#     multilaunch.sh 'Something' '/usr/games/something' 'Something' '' 'Something + Extra' '-extra'

# Even the base args may be empty if each option is a different executable:
#     multilaunch.sh 'Things' '' 'Something' '/usr/games/something' 'Another Thing' '/usr/games/anotherthing'

# If installed, figlet and/or lolcat will be used to make the base title look
# nice and fancy.

# This script comes with no warranty of any kind. Use it at your own risk.
# Moreover, anything that may appear to be a bug is actually a feature, as I
# hereby declare that this script is supposed to do precisely whatever it does,
# unless it breaks something on your system in which case that's user error.

if [ $# -eq 0 ]
then
	echo "Usage: ${USAGE}"
	exit 2
fi

if command -v figlet > /dev/null
then
	if command -v lolcat > /dev/null
	then
		figlet "$1" | lolcat
	else
		figlet "$1"
	fi
elif command -v lolcat > /dev/null
then
	lolcat -a <<< "$1"
else
	echo "$1"
fi
echo
base_args="$2"
shift 2
i=0
choices=()
while [ $# -gt 1 ]
do
	i=$(($i+1))
	echo "[${i}] $1"
	choices+=("${base_args} $2")
	shift 2
done
if [ $# -eq 1 ]
then
	echo "Unused odd argument: $1"
fi
echo
read -p "Which game? " input
if [ ${input} -gt 0 ] && [ ${input} -le ${i} ]
then
	sh -c "${choices[$((${input}-1))]}"
else
	exit 1
fi
