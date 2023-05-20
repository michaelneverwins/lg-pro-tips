#!/bin/bash

# This script simply uses `xrandr` to set every active monitor to "auto" mode.
# This is good for resetting my display resolution after a game changes it and
# then fails to change it back on exit (which happens to me when I run Wolf4SDL
# and a few others). To that end, the script can also wrap a command given as
# arguments, e.g.:
#     ./xrandr-auto.sh wolf4sdl
# Yes, I know, I really should just install gamescope or something.

# I can't say that I have total confidence in the `grep` below, but it works on
# my machine. I suppose it will break if some update to `xrandr` changes the
# output format. For what it's worth, `xrandr` simply ignores bogus `--output`
# arguments, so in the absolute worst case, I would expect this script to do
# nothing. This assumes, of course, that the user actually wants to use the
# `--auto` option for every active monitor (which, at least on my machine,
# reverts to the native resolution). Obviously, if that is not desired, then
# this should not be used (or should be modified before use). In any case...

# This script comes with no warranty of any kind. Use it at your own risk.

$@
for monitor in $(
	xrandr --listactivemonitors | grep -oP '^\s*\d+:\s+\+\*?\K\S+'
)
do
	echo --output ${monitor} --auto
done | xargs xrandr
