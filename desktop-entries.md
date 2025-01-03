# Desktop Entries
Desktop shortcuts and menu shortcuts in Linux are defined by files called desktop entries. These are simple text files with the extension `.desktop`, and this is a brief guide to how they work. You don't necessarily need to create or edit these files by hand, but you can — and besides, the exact instructions for dealing with shortcuts using GUIs may vary between desktop environments, whereas the file format itself and other details below are standardized.

## Locations

### Desktop shortcuts
Desktop shortcuts are typically defined by desktop entry files located in your `~/Desktop` directory. For these to work, you may need to make them executable (although this step will probably be done already for any desktop shortcuts not created manually by you):
```bash
chmod u+x ~/Desktop/*.desktop
```

### Menu shortcuts

#### System applications
System-wide menu shortcuts, usually created automatically for applications installed by your package manager, are defined by desktop entries typically located in `/usr/share/applications` and/or `/usr/local/share/applications`. These directories are owned by `root`, but you can modify the associated menu shortcuts without special permissions by overriding the system-wide desktop entries with user-specific desktop entries (see below).

#### User applications
User-specific menu shortcuts are defined by desktop entries typically located in `~/.local/share/applications`. This directory is owned by you, so you can modify the files therein as you like. If a desktop entry in this user directory has the same file name as a desktop entry in the `root`-owned system directory, the one in the user directory takes precedence. Therefore, if you want to change the icon image or other details of a menu shortcut defined in `/usr/share/applications` without `root` access, you can make a copy of it in your `~/.local/share/applications` and modify the copy.

#### Other
Desktop entries may also be found in other locations, such as `/var/lib/flatpak/exports/share/applications` for Flatpak programs and `/var/lib/snapd/desktop/applications` for applications installed via Snap.

## Format
To demonstrate the basic format of the desktop entry, here's the shortcut I created for [*Darkula*](https://locomalito.com/games/darkula), a free game by [Locomalito](https://locomalito.com/):
```
[Desktop Entry]
Name=Darkula
Comment=Go bring darkness back to the night
Path=/home/michael/.local/share/games/Darkula
Exec=wine Darkula.exe
Icon=/home/michael/.local/share/games/Darkula/Darkula.ico
Terminal=false
Type=Application
Categories=Game;
```
* The `Name` value is the name displayed on the shortcut. (The file name may be something else.)
* The `Comment` value is some text that may be displayed in your menu.
* The `Path` value is the working directory from which the program is to be executed.
  * In this case, it's the directory into which I extracted `Darkula.exe` from `darkula.zip`:
    ```bash
    wget https://locomalito.com/files/darkula.zip -P ~/Downloads
    mkdir -p ~/.local/share/games/Darkula
    unzip ~/Downloads/darkula.zip -d ~/.local/share/games/Darkula
    ```
* The `Exec` field contains the program and any arguments, as you would execute it from the command line.
  * In this case, the shortcut runs `wine` with the argument `Darkula.exe`.
  * I can simply reference `wine` by name without specifying its full location, `/usr/bin/wine`, because `/usr/bin` is included in my `$PATH` environment variable.
  * The argument to `wine` is simply `Darkula.exe`, rather than the absolute path `/home/michael/.local/share/games/Darkula/Darkula.exe`, because `wine` accepts relative paths for executables and the working directory is `/home/michael/.local/share/games/Darkula`.
  * If you want the shortcut to set an environment variable (e.g. to change `WINEPREFIX`), you should do it using the `env` command. Whereas at the command line I could get away with simply entering
    ```bash
    WINEPREFIX=~/.local/share/games/Darkula/.wine wine Darkula.exe
    ```
    to give the game its own prefix, my desktop entry would instead need to use `env` as follows:
    ```
    Exec=env WINEPREFIX=/home/michael/.local/share/games/Darkula/.wine wine Darkula.exe
    ```
* The `Icon` field defines an icon image.
  * In this case, it's the location of an icon file which I extracted from the executable. (See the next section.)

For the full specification of the file format, see [`https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html`](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html).

## Icons
If you're creating your own desktop entry, you'll probably want an icon. The `Icon` field may reference an icon by name — for example, the desktop entry for Steam simply has `Icon=steam` — but you can also put an absolute file path here, which is useful if you're creating a shortcut for something you've installed manually.

### Extracting Icons
When you install a Windows game, it won't always come with a separate image file which is suitable for shortcut icons. Windows executables often have embedded icons, so shortcuts to those programs on Windows will get icons automatically. On Linux, we can extract the icons from Windows executables as needed. A couple of useful programs are `wrestool` and `icotool`, which may be available for your Linux distribution via the `icoutils` package. The `Darkula.ico` file used in my desktop entry for *Darkula* was created using `wrestool` as follows:
```bash
cd ~/.local/share/games/Darkula
wrestool -o Darkula.ico -t 14 -x Darkula.exe
```
On my system, simply using this `.ico` file as the shortcut icon works. If that were not the case, then I could also use `icotool` to extract one or more image files from this `.ico` file. If a new file name is passed to the `-o` option, e.g.
```bash
icotool -o Darkula.png -x Darkula.ico
```
then `icotool` will extract one image file, which happens to be a 256x256 PNG image in this case. The tool has additional options for matching an appropriate image in an `.ico` file containing multiple, if you don't like what it gives you by default, but you can also just extract everything. If an existing directory is passed to the `-o` option, e.g.
```bash
icotool -o . -x Darkula.ico
```
then it will extract all images. This particular `.ico` file happens to contain five images in total, so the above `icotool` command creates `Darkula_1_16x16x32.png`, `Darkula_2_24x24x32.png`, `Darkula_3_32x32x32.png`, `Darkula_4_48x48x32.png`, and `Darkula_5_256x256x32.png`.

In general, the exact usage of these tools will vary. Run `wrestool --help` and `icotool --help` for general usage, or `man wrestool` and `man icotool` for more detailed information.

### Installing Icons
While the `Icon` field of a desktop entry will accept an absolute file path, it can also reference the name of an installed icon. Icons already installed at the system level can typically be found under `/usr/share/icons` — organized first by theme (where the `hicolor` theme effectively contains the default icons), then by size (e.g. `128x128`), and then by type (namely `apps` for application icons) — or in `/usr/share/pixmaps`. User icons (which can override the system icons) may be placed under`~/.local/share/icons` or `~/.icons`.

The `xdg-icon-resource` command can be used for installing your own icons to the appropriate folders so that your shortcuts can reference them by name. This may be preferable to referencing an absolute file path, because a name can reference a whole set of icons, thus allowing your shortcut to display an icon of the appropriate size. This isn't just a matter of scaling; a program may have aesthetically different icons at different sizes. For example, the 256x256 _Darkula_ icon is different from the others.

The following example usage of `xdg-icon-resource` would install the five _Darkula_ icons created in the previous subsection:
```bash
xdg-icon-resource install --noupdate --novendor --size 16 Darkula_1_16x16x32.png darkula
xdg-icon-resource install --noupdate --novendor --size 24 Darkula_2_24x24x32.png darkula
xdg-icon-resource install --noupdate --novendor --size 32 Darkula_3_32x32x32.png darkula
xdg-icon-resource install --noupdate --novendor --size 48 Darkula_4_48x48x32.png darkula
xdg-icon-resource install --noupdate --novendor --size 256 Darkula_5_256x256x32.png darkula
xdg-icon-resource forceupdate
```
The `--theme` option was not used and `hicolor` is the default, so this would install the icons to the following locations:
```
~/.local/share/icons/hicolor/16x16/apps/darkula.png
~/.local/share/icons/hicolor/24x24/apps/darkula.png
~/.local/share/icons/hicolor/32x32/apps/darkula.png
~/.local/share/icons/hicolor/48x48/apps/darkula.png
~/.local/share/icons/hicolor/256x256/apps/darkula.png
```
With these in place, I could then set my _Darkula_ shortcut's `Icon` value to `darkula`:
```
Icon=darkula
```
If I don't want these icons anymore, they could then be uninstalled as follows:
```bash
xdg-icon-resource uninstall --noupdate --size 16 darkula
xdg-icon-resource uninstall --noupdate --size 24 darkula
xdg-icon-resource uninstall --noupdate --size 32 darkula
xdg-icon-resource uninstall --noupdate --size 48 darkula
xdg-icon-resource uninstall --noupdate --size 256 darkula
xdg-icon-resource forceupdate
```
For more information, run `man xdg-icon-resource` to see the manual, which isn't a long read as far as manuals go.
