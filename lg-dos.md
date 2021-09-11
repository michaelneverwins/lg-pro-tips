# DOS Gaming on Linux
Stores like Steam and GOG sell a lot of old DOS games packaged with the DOS emulator DOSBox. While some of these games will have Linux-compatible versions that come with the Linux version of DOSBox, many are distributed only with the Windows version of DOSBox, and therefore their store pages will claim they are compatible only with Windows. Despite this, you can expect nearly all DOSBox-powered games from Steam, GOG, etc. to run on Linux if you just install DOSBox for Linux and configure it to run them.

Using a Linux-native DOSBox isn't strictly necessary, as DOSBox-powered games packaged only for Windows will often run with Wine or Proton — which might be the "easiest" option, particularly for running Steam's ostensibly Windows-only DOS games. In fact, some of Steam's DOSBox-powered games work well enough with Proton that they are officially supported by Steam Play. (For example, *Commander Keen Complete Pack* was verified for Proton 3.7-8 by Valve testing and will run with that version of Proton by default.) So a DOS game packaged for Windows might "just work" out of the box on Linux, if you really want to use a Linux-to-Windows compatibility layer to run the Windows version of a multi-platform DOS emulator. However, that's probably not ideal for any game.

## DOSBox for Linux
Installing DOSBox on Ubuntu, or an Ubuntu-based distribution like Linux Mint, is easy:
```bash
sudo apt install dosbox
```
Explaining how to *run* DOSBox, on any operating system, is a bit outside the scope of this guide. It generally works on Linux in the same way as on Windows. If you're playing a game that was packaged with DOSBox by a PC game retailer, then all of the necessary configuration has probably been done for you. However, if you want a tutorial or a manual, you can find both on the DOSBox official site: [`https://www.dosbox.com/`](https://www.dosbox.com/)

### DOSBox Staging
DOSBox Staging ([`https://github.com/dosbox-staging/dosbox-staging`](https://github.com/dosbox-staging/dosbox-staging)) is fork of DOSBox that fixes some issues present in regular DOSBox and adds some features. It's also required — or, at least, strongly recommended — for Boxtron (see below).

There's a PPA for Ubuntu and Mint users (see [`https://dosbox-staging.github.io/downloads/linux/`](https://dosbox-staging.github.io/downloads/linux/)), so you can install DOSBox Staging like this:
```bash
sudo add-apt-repository ppa:feignint/dosbox-staging
sudo apt-get update
sudo apt install dosbox-staging
```
(Note: This *replaces* regular DOSBox if you already have that installed, but this is probably fine unless you have some odd reason for keeping both versions.)

You could also just grab the latest DOSBox Staging release from GitHub ([`https://github.com/dosbox-staging/dosbox-staging/releases/latest`](https://github.com/dosbox-staging/dosbox-staging/releases/latest)) and unpack it somewhere. This allows you to have DOSBox Staging installed alongside DOSBox. However, if you install DOSBox Staging manually, you might also need to install some dependencies manually (as documented on GitHub).

## Boxtron
If you want to use Linux DOSBox to play a Steam game that came with Windows DOSBox, a tool called Boxtron will do a lot of the work for you. In a nutshell, Boxtron is a Steam Play compatibility tool which allows Steam to use Linux DOSBox (rather than Proton) to run games which come packaged with Windows DOSBox.

See the GitHub page ([`https://github.com/dreamer/boxtron`](https://github.com/dreamer/boxtron)) for instructions on installing Boxtron and its dependencies. Once it's installed and Steam is restarted, you can open up any DOSBox-powered Steam game's properties window and select Boxtron.

If you want Boxtron to use some DOSBox executable which is not identified by running `which dosbox`, this will require editing the `cmd = ...` line in the `[dosbox]` section of `~/.config/boxtron.conf`. For more on configuration of Boxtron, see the wiki ([`https://github.com/dreamer/boxtron/wiki/Configuration`](https://github.com/dreamer/boxtron/wiki/Configuration)).

### with Non-Steam Games
Boxtron can also be used with non-Steam games if you add them to your local Steam library using Steam's "Add a Non-Steam Game" feature. This is especially easy for GOG games, because Boxtron comes with an `install-gog-game` script (see [`https://github.com/dreamer/boxtron#gog-games`](https://github.com/dreamer/boxtron#gog-games)). Given a GOG game installer, this script will unpack the game and create a `.desktop` file which can be easily added to Steam. The script requires `python3` and `wine`.

## Roberta
Boxtron's sister project Roberta is a Steam Play compatibility tool which uses the native Linux version of ScummVM to run games which came packaged with the Windows version of ScummVM. It's relevant here for two reasons: firstly because many games supported by ScummVM were originally DOS games, and secondly because Roberta works with ScummVM-compatible Steam games which are packaged only with DOSBox (such as the *Phantasmagoria* series). You can manually set up ScummVM to run these games, but simply using Roberta as a compatibility tool makes it much easier.

## Source Ports
For many DOS games, whether on Linux or Windows, you're probably better off using a source port. The classic *Doom* engine games have numerous Linux-compatible source ports, for example. We won't go into detail about specific source ports here, for DOS games specifically or otherwise, but the following will cover a lot of them:
* There's another Steam Play compatibility tool from the creator of Boxtron and Roberta, called Luxtorpeda ([`https://github.com/luxtorpeda-dev/luxtorpeda`](https://github.com/luxtorpeda-dev/luxtorpeda)), for automatically running Steam games with their respective Linux-native engines. Supported games: [`https://luxtorpeda-dev.github.io/packages.html`](https://luxtorpeda-dev.github.io/packages.html)
* GameDataPackager ([`https://wiki.debian.org/Games/GameDataPackager`](https://wiki.debian.org/Games/GameDataPackager)) is a command-line tool which, if provided data files of certain non-free games, packages and installs them along with the dependencies (e.g. source ports) required to play them on Linux. Supported games: [`https://salsa.debian.org/games-team/game-data-packager/tree/master/data`](https://salsa.debian.org/games-team/game-data-packager/tree/master/data)
* Open Source Game Clones ([`https://osgameclones.com/`](https://osgameclones.com/)) is a web site listing, among other things, source ports and open-source reimplementations of various games, some of which were originally released for DOS.
