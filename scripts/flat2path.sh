#!/bin/bash -e

# For each Flatpak program with a desktop entry file (or link) located in
# /var/lib/flatpak/exports/share/applications/, this script creates a one-line
# script in ~/.local/bin/ to run the corresponding program. Each script's name
# is the last part of the Flatpak program's name, converted to lowercase. For
# example, if the Flatpak version of Lutris is installed, this script should
# detect the desktop entry located at
#   /var/lib/flatpak/exports/share/applications/net.lutris.Lutris.desktop
# or
#   ~/.local/share/flatpak/exports/share/applications/net.lutris.Lutris.desktop
# for a system install or user install, respectively, and create a script at
#   ~/.local/bin/lutris
# which contains
#   flatpak run net.lutris.Lutris

# The purpose of this script is simply to save me the trouble of typing the
# entire `flatpak run foo.bar.something` command when I want to run something.
# For this script's intended usage, ~/.local/bin/ should be in the user's PATH.
# If executed as root, this script will create scripts in /usr/local/bin/
# instead, though this is only because putting them in ~root/.local/bin/ would
# most likely be useless, not because I would ever encourage running some guy's
# scripts from GitHub with sudo.

# This script assumes the following:
# * that a Flatpak program executed as `flatpak run foo.bar.something` will
#   have a desktop entry named "foo.bar.something.desktop";
# * that Flatpak program desktop entries' names never contain spaces;
# * that Flatpak desktop entries (or links to them) are found in the locations
#   specified above.

# Moreover, it is assumed that there is only one copy of each Flatpak program
# installed. Specifically, if the same Flatpak program is installed system-wide
# and for the current user, this script will not differentiate between the two.
# It will simply create one script in (or, rather, create it twice with the
# second copy overwriting the first), and the command executed by that script
# will be `flatpak run ...` with no `--user` or `--system` argument. I assume
# Flatpak will run the system-installed copy in this case.

# This script comes with no warranty of any kind. Use it at your own risk.

if [ "$EUID" -eq 0 ]
then
	runner_dir=/usr/local/bin
else
	runner_dir=~/.local/bin
fi

last_lower='s/.\+\.\([^\.]\+\)$/\L\1/'

for desktop_entry in \
	/var/lib/flatpak/exports/share/applications/*.desktop \
	~/.local/share/flatpak/exports/share/applications/*.desktop
do
	if [ ! -f ${desktop_entry} ]
	then
		continue
	fi
	flatpak_name=$(basename ${desktop_entry} .desktop)
	runner_script=${runner_dir}/$(sed -e ${last_lower} <<< ${flatpak_name})
	echo "flatpak run ${flatpak_name}" > ${runner_script}
	chmod -v u+x ${runner_script}
done
