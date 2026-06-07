# Setting Up Quake (with Music) from GOG Installer
On a Debian-based distribution such as Linux Mint, one can easily install _Quake_ and its mission packs from GOG's installer using the `game-data-packager` program as follows:
```sh
sudo apt install game-data-packager
game-data-packager --install quake \
    --package quake-registered --package quake-music \
    --package quake-armagon --package quake-armagon-music \
    --package quake-dissolution --package quake-dissolution-music \
    -- ~/Downloads/setup_quake_the_offering_2.0.0.6.exe
```
This program is actually pretty neat; it will create `.deb` packages for the game assets and install them to your system in locations used by the Quakespasm source port, which is then marked as a dependency and also installed automatically. At the time of writing, it will even download the soundtracks in Ogg Vorbis format so that Quakespasm can play the music.

But wait... isn't the soundtrack included in GOG's installer? Well, yes. It's not in Ogg Vorbis format, but we can convert it to that format ourselves, which is what this guide will demonstrate. Note that simply downloading the soundtrack is the easy solution — and is probably reliable enough, assuming the site from which `game-data-packager` downloads it is allowed to host it. However, what if that site _isn't_ reliable and goes down? Or what if we're afraid the police will knock on our door if we download copyrighted music? More generally, what if we just don't want to rely on `game-data-packager` to compile the required assets in the first place, because we don't want them installed as system packages owned by `root`? Or what if we're using a distribution which doesn't have `game-data-packager` (but does happen to have all of the other programs to be used in the steps below)?

The steps below will result in approximately the same set-up that `game-data-packager` would do for you, with the following differences:
* Soundtracks are extracted from the GOG installer instead of downloaded.
* Game assets are placed in user-owned folders rather than installed as system packages.

## Unpacking the installer (required files only)
We will use `innoextract` for this.
```sh
sudo apt install innoextract
```
General usage is just to unpack all the files from a GOG installer:
```sh
innoextract ~/Downloads/setup_quake_the_offering_2.0.0.6.exe
```
However, that will include a _lot_ of files we don't need for running the game natively on Linux. So we can do this instead (and throw the outputs in a subfolder of `/tmp` because even the files that come out of this command will include more than we need to keep):
```sh
mkdir /tmp/quake-unpack  # This folder can be deleted after we're done.
innoextract ~/Downloads/setup_quake_the_offering_2.0.0.6.exe \
    -I app/Id1/PAK0.PAK -I app/Id1/PAK1.PAK -I app/game.gog -I app/game.cue \
    -I app/hipnotic/pak0.pak -I app/gamea.gog -I app/gamea.cue \
    -I app/rogue/pak0.pak -I app/gamed.gog -I app/gamed.cue \
    -d /tmp/quake-unpack/
```
Note: If the `.exe` filename above does not match the one you have, the steps below may not work. GOG still distributes the `.exe` referenced above at the time of writing, but this might change in the future. (This is the original _Quake_, by the way, not _Quake Enhanced_.)

## Installing the `.pak` files
We might as well do the easy part first.
```sh
mkdir -p ~/.quakespasm/id1
mv /tmp/quake-unpack/app/Id1/PAK0.PAK ~/.quakespasm/id1/pak0.pak
mv /tmp/quake-unpack/app/Id1/PAK1.PAK ~/.quakespasm/id1/pak1.pak
mkdir -p ~/.quakespasm/hipnotic
mv /tmp/quake-unpack/app/hipnotic/pak0.pak ~/.quakespasm/hipnotic/
mkdir -p ~/.quakespasm/rogue
mv /tmp/quake-unpack/app/rogue/pak0.pak ~/.quakespasm/rogue/
```

## Creating and installing the `.ogg` files
Now here's the fun part. It will require some additional programs, `bchunk` and `oggenc`. The latter is provided by the `vorbis-tools` package on Linux Mint.
```sh
sudo apt install bchunk vorbis-tools
```
Use `bchunk` to split the `.gog` files into `.iso` and `.wav` files, and then use `oggenc` to convert the resulting `.wav` files to `.ogg` files:
```sh
mkdir -p ~/.quakespasm/id1/music
bchunk -w /tmp/quake-unpack/app/game.gog /tmp/quake-unpack/app/game.cue ~/.quakespasm/id1/music/track
oggenc ~/.quakespasm/id1/music/track*.wav
rm ~/.quakespasm/id1/music/track*.wav ~/.quakespasm/id1/music/track01.iso
mkdir -p ~/.quakespasm/hipnotic/music
bchunk -w /tmp/quake-unpack/app/gamea.gog /tmp/quake-unpack/app/gamea.cue ~/.quakespasm/hipnotic/music/track
oggenc ~/.quakespasm/hipnotic/music/track*.wav
rm ~/.quakespasm/hipnotic/music/track*.wav ~/.quakespasm/hipnotic/music/track01.iso
mkdir -p ~/.quakespasm/rogue/music
bchunk -w /tmp/quake-unpack/app/gamed.gog /tmp/quake-unpack/app/gamed.cue ~/.quakespasm/rogue/music/track
oggenc ~/.quakespasm/rogue/music/track*.wav
rm ~/.quakespasm/rogue/music/track*.wav ~/.quakespasm/rogue/music/track01.iso
```
(We don't need to keep the `.wav` files once we have our `.ogg` files. We don't need to keep the `.iso` files either, so they are also deleted by the commands above, but you can mount them if you want to see what was on the original CDs.)

## Running the game and its mission packs
To install Quakespasm:
```sh
sudo apt install quakespasm
```
To run _Quake_:
```sh
quakespasm
```
To run _Scourge of Armagon_:
```sh
quakespasm -hipnotic
```
To run _Dissolution of Eternity_:
```sh
quakespasm -rogue
```
