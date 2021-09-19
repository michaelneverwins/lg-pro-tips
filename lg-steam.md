# Linux Gaming on Steam

## How do I install Steam on Linux?
It should be easy. If you're using a distro like Ubuntu or Mint, you can just search for it in your software manager and click "Install". If you want to use the terminal, just do this (or your package manager's equivalent "install a program" command):
```
sudo apt install steam
```
You can also download a `.deb` file from [`https://store.steampowered.com/about/`](https://store.steampowered.com/about/) and install it that way, if it's not in your distro's package repository.

## How do I play Steam games on Linux?
Once Steam is installed, downloading and playing games (nominally) works the same way as on Windows:
* Select a game in your library.
* Click the blue "download" button.
* Click the green "play" button.

If the "download" button is gray and cannot be clicked, and is accompanied by a note that the game is available on Windows, then you need to update your Steam Play settings; see below.

## How do I install Windows games?
* Open the Settings window.
* Go to the "Steam Play" tab.
* Make sure **both** of the following options are enabled:
  * "Enable Steam Play for supported titles"
     * This will allow installation of Windows games officially supported by Steam Play.
  * "Enable Steam Play for all other titles"
     * This will additionally allow installation all other Windows games, including the vast majority which haven't been manually verified for Proton compatibility by Valve.
     * The Proton version selected here will be used for all games by default, except for officially supported games which will use Valve's selected Proton version by default.

  ![](images/steam-global-compatibility-settings.png)

* Once your settings are saved, you'll need to restart Steam for these changes to take effect, after which you should be able to install any Windows game.

### Huh? What's Proton?
It's a compatibility layer for Windows games on Linux, based on Wine.

#### Huh? What's Wine?
It's a compatibility layer for Windows software on Linux.

### How do I override the Proton version for a specific game?
* Right-click the game in your library.
* Select "Properties...".
* Go to the "Compatibility" tab.
* Enable the "Force the use of a specific Steam Play compatibility tool" option.
* Select a specific Proton version from the drop-down menu which appears.

  ![](images/steam-game-compatibility-options.png)

### How do I know which version of Proton a specific game is using?
* Select a game in your library and click the "Show more details" button on the right-hand side of the window.

  ![(It's the button with the "i" in a circle.)](images/steam-game-show-more-details.png)
  
* The bottom of the expanded area should indicate which Proton version, if any, is being used.

  ![](images/steam-game-expanded-details.png)

## How do I use Proton to play a Windows game?
For Windows games in your Steam library, Steam runs Proton for you. Once you have Steam Play set up and the game is installed, just click "play". When launching a Windows game with Steam Play for the first time, you'll see a message like this one pop up:

![](images/steam-game-first-steam-play-launch.png)

Click "continue" and Steam will attempt to run the game. It's not guaranteed to work, but it often does.

## Why isn't this Windows game working?
If you're having trouble running a Windows game with Proton, try looking it up on ProtonDB ([`https://www.protondb.com/`](https://www.protondb.com/)). This should give you an idea of whether the game is known to have issues, or whether it's just you. If there's a known fix for the game, it will usually be mentioned in one of the reports. Despite the questionable rating system, ProtonDB is a good resource. In some cases, you might also want to take a look at PC Gaming Wiki ([`https://www.pcgamingwiki.com/`](https://www.pcgamingwiki.com/)). If an older game requires patching to be suitable for modern Windows then it might require the same patching on Linux.

### Why isn't this Windows game's patch or mod working?
Some patches may require additional launch options. For example, ThirteenAG's widescreen fix for *Max Payne* ([`https://thirteenag.github.io/wfp#mp1`](https://thirteenag.github.io/wfp#mp1)) works by adding a DLL file, `d3d8.dll`, and you'll need to add `WINEDLLOVERRIDES="d3d8=n,b" %command%` to the game's launch options in order to make that DLL file work when running the game with Proton. With any luck, a game's ProtonDB reports will mention any non-obvious steps for applying popular patches to Windows games on Linux.

### How do I add the launch options recommended by this ProtonDB report?
* Right-click the game in your library.
* Select "Properties...".
* Go to the "General" tab.
* Type or paste the launch option(s) into the text field.

  ![](images/steam-game-launch-options.png)

  * The launch options field is often used to set environment variables, e.g. `PROTON_USE_WINED3D=1`; these need to be followed by `%command%`.
  * Command-line arguments to the game itself, e.g. `-window` to enable windowed mode, may then follow `%command%`.
  * The `%command%` part may be omitted if you're not going to put anything before it.

Some launch options are documented in the Proton README on GitHub ([`https://github.com/ValveSoftware/Proton/`](https://github.com/ValveSoftware/Proton/)).

## Why isn't this Linux game working?
Sometimes developers don't do a good job of making Linux builds for their games. In particular, games developed with GameMaker Studio are often known to have broken Linux ports.

You can try forcing Steam to run the Windows version of the game with Proton.

### How do I run the Windows version of a supposedly Linux-compatible game whose Linux build is not working?
* Right-click the game in your library.
* Select "Properties...".
* Go to the "Compatibility" tab.
* Enable the "Force the use of a specific Steam Play compatibility tool" option.
* Select a specific Proton version from the drop-down menu which appears.
* If you already had the Linux version of the game installed, Steam will now replace it with the Windows version.

## How do I view only my Linux games?
Interestingly, the Steam client for Linux does not seem to provide an easy way to see, at a glance, which of the games in one's library are natively Linux-compatible. The option technically does exist, but does not work as you might expect. You may have noticed this "games that run on Linux" filter represented by a little penguin button:

![](images/steam-library-linux-filter.png)

However, this is not a filter for Linux-native games. If you've enabled Steam Play for all games, then Steam thus considers all Windows games to be runnable on Linux; in this case, the filter really has no effect. You can disable Steam Play for all games in order to make this filter show only the games in your library which run natively on Linux, but changing that option requires a restart of the Steam client.

## Where are my games installed?
By default, your games will be installed somewhere under your home directory, typically under `~/.steam/root/steamapps/common`. This includes both Linux games and Windows games. Meanwhile, each Windows game's Wine prefix will be under `~/.steam/root/steamapps/compatdata`.

## How do I install other Steam Play compatibility tools?
You'll have to follow the README for the compatibility tool you're trying to install, but these installations typically involve unpacking some files into the `~/.steam/root/compatibilitytools.d` folder and then restarting Steam.

### What other Steam Play compatibility tools are available?
Here are a few:

* Proton-GE ([`https://github.com/GloriousEggroll/proton-ge-custom`](https://github.com/GloriousEggroll/proton-ge-custom)), a custom build of Proton which fixes issues in some games.
* Steam Tinker Launch ([`https://github.com/frostworx/steamtinkerlaunch`](https://github.com/frostworx/steamtinkerlaunch)), a tool for automatically applying tweaks to games and customizing how they run.
  * This can be used either as a Steam Play compatibility tool or as a launch option (`stl %command%`).
* Boxtron ([`https://github.com/dreamer/boxtron`](https://github.com/dreamer/boxtron)), for running DOSBox-powered games with the native Linux version of DOSBox if Steam provides only a Windows version.
* Roberta ([`https://github.com/dreamer/roberta`](https://github.com/dreamer/roberta)), for running ScummVM-powered games with the native Linux version of ScummVM if Steam provides only a Windows version.
* Luxtorpeda ([`https://github.com/luxtorpeda-dev/luxtorpeda`](https://github.com/luxtorpeda-dev/luxtorpeda)), for running various games with their respective Linux-native source ports or engine re-implementations.
  * Supported games: [`https://luxtorpeda-dev.github.io/packages.html`](https://luxtorpeda-dev.github.io/packages.html)

## Other miscellaneous notes:
* Protontricks ([`https://github.com/Matoking/protontricks`](https://github.com/Matoking/protontricks)) is a Winetricks wrapper for use with Steam Play and Proton.
  * Winetricks ([`https://github.com/Winetricks/winetricks`](https://github.com/Winetricks/winetricks)) helps to automate various tweaks such as changing Wine's configuration and installing missing dependencies.
* Lutris ([`https://lutris.net/`](https://lutris.net/)) can import your games from Steam and other stores, and might help you run them more easily.
* GameHub ([`https://github.com/tkashkin/GameHub/`](https://github.com/tkashkin/GameHub/)) also integrates with Steam and other stores.
* GameDataPackager ([`https://wiki.debian.org/Games/GameDataPackager`](https://wiki.debian.org/Games/GameDataPackager)), a tool which packages non-free game data for use with free Linux-native engines, is able to locate installed Steam games automatically.
