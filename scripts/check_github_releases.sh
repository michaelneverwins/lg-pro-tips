#!/bin/bash

# This Bash script checks a configurable list of GitHub repositories for new
# releases. If the configuration file indicated by the `CONFIG` variable below
# does not exist, a file will be created; the user must then edit the file to
# specify one or more repositories, or uncomment some of the included examples.
# The first time the script checks a repository, and then each time the latest
# release tag has changed since the last check, the user will be notified of
# the release. This information will be printed to the terminal if possible;
# otherwise, `notify-send` will be used to send a desktop notification. This
# allows the script to be executed in the background, e.g. as a cron job or
# startup application.

# This script assumes the following:
# * that colored output using ANSI escape sequences is supported (for terminal
#   usage);
# * that the `notify-send` command is supported (for non-terminal usage);
# * that the configuration file indicated by the `CONFIG` variable set below is
#   not used by any other program.

# This script comes with no warranty of any kind. Use it at your own risk.

CONFIG_DIR=${XDG_CONFIG_HOME:-${HOME}/.config}
CONFIG=${CONFIG_DIR}/github_releases

function _communicate {
	if [ -t 1 ]
	then
		echo -e "\e[${4};1m${1}:\e[22m ${2}\e[0m"
	else
		notify-send -i ${3} "${1}" "${2}"
	fi
}

function show_info {
	_communicate "${1}" "${2}" dialog-information 33
}

function show_release {
	_communicate "${1}" "${2}" software-update-available 32
}

function show_error {
	_communicate "${1}" "${2}" dialog-error 31
}

if [ ! -f "${CONFIG}" ]
then
	mkdir -p $(dirname "${CONFIG}")
	echo "# Configuration file for: $(realpath ${0})
# Specify one or more GitHub repositories below, one per line, by entering the
# portion of the URL that comes after 'https://github.com/'. Each time the
# script runs, it will add the latest release tag to each line after a colon.
# Examples (delete '#' to enable):
#GloriousEggroll/proton-ge-custom
#ZDoom/gzdoom
#ZDoom/Raze
#Aleph-One-Marathon/alephone
#bibendovsky/bstone
#noxworld-dev/opennox
#dosbox-staging/dosbox-staging
#flightlessmango/MangoHud
#Merrit/nyrna
#lutris/lutris
" > ${CONFIG}
	show_info "${CONFIG}" "Created default configuration file"
	exit 0
fi

readarray -t lines <<< $(egrep "^[^#].+" "${CONFIG}")
if [ -z "${lines[0]}" ]
then
	show_error "${CONFIG}" "No repositories specified"
	exit 1
fi

for line in "${lines[@]}"
do
	readarray -d ":" -t parts <<< ${line}
	repo=$(sed -E s/"\s+"//g <<< ${parts[0]})
	old=$(sed -E s/"\s+"//g <<< ${parts[1]})
	url="https://github.com/${repo}/releases/latest"
	new=$(curl -i -s ${url} | grep -oP 'releases/tag/\K[^"\r\n]+')
	if [ -z "${new}" ]
	then
		show_error "${repo}" "Failed to check latest release"
	elif [ "${new}" != "${old}" ]
	then
		show_release "${repo}" "New release: ${new}"
		sed -E s?"^\s*${repo}.*"?"${repo} : ${new}"? -i ${CONFIG}
	fi
done
