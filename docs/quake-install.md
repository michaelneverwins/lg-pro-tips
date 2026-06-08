# Setting Up _Quake_ (with Music) from GOG Installer
On a Debian-based distribution such as Linux Mint, one can easily install _Quake_ and its mission packs from GOG's installer using the `game-data-packager` program as follows:
```sh
sudo apt install game-data-packager
game-data-packager --install quake \
    --package quake-registered --package quake-music \
    --package quake-armagon --package quake-armagon-music \
    --package quake-dissolution --package quake-dissolution-music \
    -- ~/Downloads/setup_quake_the_offering_2.0.0.6.exe
```
This program is actually pretty neat; it will create `.deb` packages for the game assets and install them to your system in locations used by the QuakeSpasm source port, which is then marked as a dependency and also installed automatically. At the time of writing, it will even download the soundtracks in Ogg Vorbis format so that QuakeSpasm can play the music.

But wait... isn't the soundtrack included in GOG's installer? Well, yes. It's not in Ogg Vorbis format, but we can convert it to that format ourselves, which is what this guide will demonstrate. Note that simply downloading the soundtrack is the easy solution — and is probably reliable enough, assuming the site from which `game-data-packager` downloads it is allowed to host it. However, what if that site _isn't_ reliable and goes down? Or what if we're afraid the police will knock on our door if we download copyrighted music? More generally, what if we just don't want to rely on `game-data-packager` to compile the required assets in the first place, because we don't want them installed as system packages owned by `root`? Or what if we're using a distribution which doesn't have `game-data-packager` (but does happen to have all of the other programs used in this guide)?

The steps below will result in approximately the same set-up that `game-data-packager` would do for you, with the following differences:
* Soundtracks are extracted from the GOG installer instead of downloaded.
* Game assets are placed in user-owned folders rather than installed as system packages.
* Creation of [desktop entries](desktop-entries.md) is not included (nor is any other fancy stuff that `game-data-packager` might be doing under the hood beyond gathering the non-free files needed by QuakeSpasm).

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
    -d /tmp/quake-unpack/ -L
```
The `-L` option used here makes all output filenames lowercase, so that `app/Id1/PAK*.PAK` become `app/id1/pak*.pak` to match the capitalization QuakeSpasm expects.

Note: If the `.exe` filename referenced above does not match the one you have, the steps in this guide may not work. GOG still distributes the `.exe` referenced above at the time of writing, but this might change in the future. (This is the original _Quake_, by the way, not _Quake Enhanced_.)

## Installing the `.pak` files
We might as well do the easy part first.
```sh
# Quake
mkdir -p ~/.quakespasm/id1
mv /tmp/quake-unpack/app/id1/pak*.pak ~/.quakespasm/id1/
# Mission Pack 1: Scourge of Armagon
mkdir -p ~/.quakespasm/hipnotic
mv /tmp/quake-unpack/app/hipnotic/pak0.pak ~/.quakespasm/hipnotic/
# Mission Pack 2: Dissolution of Eternity
mkdir -p ~/.quakespasm/rogue
mv /tmp/quake-unpack/app/rogue/pak0.pak ~/.quakespasm/rogue/
```

## Creating and installing the music files
Now here's the "fun" part: The music files have to be extracted from disc images that we got from the installer.

We can use `bchunk` with the `.cue` files to split the `.gog` files into `.iso` and `.wav` files:
```sh
sudo apt install bchunk
# Quake
mkdir -p /tmp/quake-unpack/id1-chunks
bchunk -w /tmp/quake-unpack/app/game.gog /tmp/quake-unpack/app/game.cue /tmp/quake-unpack/id1-chunks/track
# Mission Pack 1: Scourge of Armagon
mkdir -p /tmp/quake-unpack/hipnotic-chunks
bchunk -w /tmp/quake-unpack/app/gamea.gog /tmp/quake-unpack/app/gamea.cue /tmp/quake-unpack/hipnotic-chunks/track
# Mission Pack 2: Dissolution of Eternity
mkdir -p /tmp/quake-unpack/rogue-chunks
bchunk -w /tmp/quake-unpack/app/gamed.gog /tmp/quake-unpack/app/gamed.cue /tmp/quake-unpack/rogue-chunks/track
```
QuakeSpasm can actually play the resulting `.wav` files, so we _could_ just install them to our QuakeSpasm folder now and be done with it. However, recall that the soundtracks that `game-data-packager` would download are in `.ogg` format, so there's one more step if we want our manually installed assets to match what `game-data-packager` would fetch for us. (What difference does it make? Well, `.ogg` files are significantly smaller. So if we make `.ogg` files and ditch these `.wav` files, then we will be saving some space.)

### Option 1: keep `.wav` format
If we want to use the `.wav` files, they just need to be placed in `music` folders next to where we put the `.pak` files:
```sh
# Quake
mkdir -p ~/.quakespasm/id1/music
mv /tmp/quake-unpack/id1-chunks/track*.wav ~/.quakespasm/id1/music/
# Mission Pack 1: Scourge of Armagon
mkdir -p ~/.quakespasm/hipnotic/music
mv /tmp/quake-unpack/hipnotic-chunks/track*.wav ~/.quakespasm/hipnotic/music/
# Mission Pack 2: Dissolution of Eternity
mkdir -p ~/.quakespasm/rogue/music
mv /tmp/quake-unpack/rogue-chunks/track*.wav ~/.quakespasm/rogue/music/
```
### Option 2: convert to `.ogg` format
Alternatively (perhaps preferably), the `oggenc` program (which is provided by the `vorbis-tools` package on Linux Mint) can be used to convert our `.wav` files to smaller `.ogg` files, which are to be placed in `music` folders next to where we put the `.pak` files:
```sh
sudo apt install vorbis-tools
# Quake
oggenc /tmp/quake-unpack/id1-chunks/track*.wav
mkdir -p ~/.quakespasm/id1/music
mv /tmp/quake-unpack/id1-chunks/track*.ogg ~/.quakespasm/id1/music/
# Mission Pack 1: Scourge of Armagon
oggenc /tmp/quake-unpack/hipnotic-chunks/track*.wav
mkdir -p ~/.quakespasm/hipnotic/music
mv /tmp/quake-unpack/hipnotic-chunks/track*.ogg ~/.quakespasm/hipnotic/music/
# Mission Pack 2: Dissolution of Eternity
oggenc /tmp/quake-unpack/rogue-chunks/track*.wav
mkdir -p ~/.quakespasm/rogue/music
mv /tmp/quake-unpack/rogue-chunks/track*.ogg ~/.quakespasm/rogue/music/
```

## Clean-up
If we made `.ogg` files, we don't need to keep the `.wav` files (created at `/tmp/quake-unpack/*-chunks/track*.wav` by the commands above). We also don't need to keep the `.iso` files (likewise created at `/tmp/quake-unpack/*-chunks/track01.iso`), but you can mount them if you want to see what was on the original CDs. Finally, we don't need the `.gog` and `.cue` files that were extracted from the installer (`/tmp/quake-unpack/app/*.{gog,cue}`). Following the instructions above, all of this should have ended up in `/tmp/quake-unpack` which we can now delete (although anything under `/tmp` will typically be cleared on reboot anyway):
```sh
rm -r /tmp/quake-unpack
```

## Running the game and its mission packs
To install QuakeSpasm:
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

# As for _Quake II_...
At the time of writing, the current GOG installer for the original (not _Enhanced_) version of _Quake II_ plus its mission packs — `setup_quake2_quad_damage_2.0.0.3.exe` — contains music files already in `.ogg` format, so no use of `bchunk` or `oggenc` is needed.

Installing these games with `game-data-packager` as
```sh
game-data-packager --install quake2 \
    --package quake2-full-data --package quake2-music \
    --package quake2-reckoning-data --package quake2-reckoning-music \
    --package quake2-groundzero-data --package quake2-groundzero-music \
    -- ~/Downloads/setup_quake2_quad_damage_2.0.0.3.exe
```
will result in 10 music tracks, `02.ogg` through `01.ogg`, in each of `/usr/share/games/quake2/baseq2/music/`, `/usr/share/games/quake2/xatrix/music/`, and `/usr/share/games/quake2/rogue/music/`.

However, the GOG installer contains 20 music tracks, `Track02.ogg` through `Track21.ogg`. Based on file sizes (the laziest way to compare but good enough here), it appears that:
* `Track02.ogg` through `Track11.ogg` are the ones that would be installed to `/usr/share/games/quake2/baseq2/music/` as `02.ogg` through `11.ogg` for _Quake II_;
* `Track12.ogg` through `Track21.ogg` are the ones that would be installed to `/usr/share/games/quake2/rogue/music/` as `02.ogg` through `11.ogg` for _Ground Zero_; and
* a mix of these two sets, i.e. 10 tracks selected from `Track02.ogg` through `Track21.ogg`, would be installed to `/usr/share/games/quake2/xatrix/music/` as `02.ogg` through `11.ogg` for _The Reckoning_.

So I assume that `game-data-packager` is correct about which game gets each music track, and I wouldn't want to figure it out manually for _The Reckoning_.

However, what `game-data-packager` does _might_ be unnecessary. The install guide for Yamagi Quake II (the source port that `game-data-packager` installs for _Quake II_) [claims](https://github.com/yquake2/yquake2/blob/QUAKE2_8_30/doc/020_installation.md#the-gogcom-release) that the music files from the GOG release can just be placed into a top-level `music/` folder, relative to the data directory, rather than `baseq2/music/` and so on. This does seem to work (as music is played when I install all tracks to `~/.yq2/music/`, with `.pak` files etc. installed to `~/.yq2/baseq2/`, `~/.yq2/xatrix/`, and `~/.yq2/rogue/`), so it's probably safe to assume that Yamagi Quake II knows which game gets each music track even when all music is in one combined folder. Also as noted in that install guide, the track names (`TrackXX.ogg`) are case sensitive, so if these files are extracted from the GOG installer using `innoextract`, the `-L` option to make all output filenames lowercase should _not_ be used.
