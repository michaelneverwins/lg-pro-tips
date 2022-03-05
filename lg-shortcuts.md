# Desktop Entries
Desktop shortcuts and menu shortcuts in Linux are defined by files called desktop entries. These are simple text files with the extension `.desktop`, and this is a brief guide to how they work. You don't necessarily need to create or edit these files by hand, the exact instructions for dealing with shortcuts using GUIs will vary between desktop environments, whereas the file format itself and other details below are standard.

## Locations

### Desktop shortcuts
Desktop shortcuts are typically defined by desktop entry files located in your `~/Desktop` directory. For these to work, you may need to make them executable (although this step will probably be done already for any desktop shortcuts not created manually by you):
```bash
chmod u+x ~/Desktop/*.desktop
```

### Menu shortcuts

#### System applications
System-wide menu shortcuts, usually created automatically for system-wide applications installed by your package manager, are defined by desktop entries typically located in `/usr/share/applications` and/or `/usr/local/share/applications`. These directories are owned by `root`, but you can modify the associated menu shortcuts without special permissions by overriding the system-wide desktop entries with user-specific desktop entries (see below).

#### User applications
User-specific menu shortcuts are defined by desktop entries typically located in `~/.local/share/applications`. This directory is owned by you, so you can modify the files therein as you like. If a desktop entry in this user directory has the same file name as a desktop entry in the `root`-owned system directory, the one in the user directory takes precedence. Therefore, if you want to change the icon image or other details of a menu shortcut defined in `/usr/share/applications`, you can make a copy of it in `~/.local/share/applications` and modify the copy.

#### Other
Desktop entries may also be found in other locations, such as `/var/lib/flatpak/exports/share/applications` for Flatpak programs and `/var/lib/snapd/desktop/applications` for applications installed via Snap.

## Format
To demonstrate the basic format of the desktop entry, here's the shortcut I created for [*Darkula*](https://locomalito.com/darkula.php), a free game by [Locomalito](https://locomalito.com/):
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
* The `Name` value is the name displayed on the shortcut. The file name may be something else.
* The `Comment` value is some text that may be displayed in your menu.
* The `Path` value is the working directory from which the program is to be executed.
  * In this case, it's the directory into which I extracted `Darkula.exe` from `Darkula.zip`:
    ```bash
    wget https://locomalito.com/juegos/Darkula.zip -P ~/Downloads
    mkdir -p ~/.local/share/games/Darkula
    unzip ~/Downloads/Darkula.zip -d ~/.local/share/games/Darkula
    ```
* The `Exec` field contains the program and any arguments, as you would execute it from the command line.
  * In this case, the shortcut runs `wine` with the argument `Darkula.exe`.
  * I can simply reference `wine` by name without specifying its full location, `/usr/bin/wine`, because `/usr/bin` is included in my `$PATH` environment variable.
  * The argument to `wine` is simply `Darkula.exe`, rather than the absolute path `/home/michael/.local/share/games/Darkula/Darkula.exe`, because `wine` accepts relative paths for executables and the working directory is `/home/michael/.local/share/games/Darkula`.
* The `Icon` field defines an icon image.
  * In this case, it's the location of an icon file which I extracted from the executable. (See the next section.)

For the full specification of the file format, see [`https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html`](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html).

## Icons
If you're creating your own desktop entry, you'll probably want an icon. The `Icon` field may reference an icon by name — for example, the desktop entry for Steam simply has `Icon=steam` — but you can also put a file path here, which is useful if you're creating a shortcut for something you've installed manually.

When you install a Windows game, it won't always come with a separate image file which is suitable for shortcut icons. Windows executables often have embedded icons, so shortcuts to those programs on Windows will get icons automatically. On Linux, we can extract the icons from Windows executables. A couple of useful programs are `wrestool` and `icotool`, which may be available for your Linux distribution via the `icoutils` package. The `Darkula.ico` file used in my desktop entry for *Darkula* was created using `wrestool` as follows:
```bash
cd ~/.local/share/games/Darkula
wrestool -o Darkula.ico -t 14 -x Darkula.exe
```
On my system, simply using this `.ico` file as the shortcut icon works. If that were not the case, then I could also use `icotool` to extract a `.png` file from the `.ico` file:
```bash
cd ~/.local/share/games/Darkula
icotool -o Darkula.png -x Darkula.ico
```
The exact usage of these tools will vary. Run `wrestool --help` and `icotool --help` for general usage, or `man wrestool` and `man icotool` for more detailed information.
