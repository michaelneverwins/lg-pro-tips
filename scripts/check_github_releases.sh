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
# * that colored output using ANSI escape sequences is supported;
# * that `notify-send` and other dependencies are installed;
# * that the configuration file indicated by the `CONFIG` variable is not used
#   by any other program.

# This script comes with no warranty of any kind. Use it at your own risk.

CONFIG=~/.config/github_releases

function info {
	if [ -t 1 ]
	then
		echo -e "\e[1m${1}\e[0m: ${2}"
	else
		notify-send "${1}" "${2}"
	fi
}

function error {
	if [ -t 1 ]
	then
		echo -e "\e[31;1m${1}\e[22m: ${2}\e[0m"
	else
		notify-send -i error "${1}" "${2}"
	fi
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
#flightlessmango/MangoHud
#Merrit/nyrna
#ytdl-org/youtube-dl
" > ${CONFIG}
	info "${CONFIG}" "Created default configuration file"
	exit 0
fi

readarray -t lines <<< $(egrep "^[^#].+" "${CONFIG}")
if [ -z "${lines[0]}" ]
then
	error "${CONFIG}" "No repositories specified"
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
		error "${repo}" "Failed to check latest release"
	elif [ "${new}" != "${old}" ]
	then
		info "${repo}" "New release: ${new}"
		sed -E s%"^\s*${repo}.*"%"${repo} : ${new}"% -i ${CONFIG}		
	fi
done
