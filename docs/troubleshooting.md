# Basic Troubleshooting

## Checking for Known Issues
The best first step is often to see if anyone else has already reported whatever issue you're having — and, with any luck, a workaround or a fix for it.
* If you're trying to run a Steam game, especially a Steam game for Windows, you might want to check the compatibility reports on ProtonDB ([`https://www.protondb.com/`](https://www.protondb.com/)).
  * The primary purpose of ProtonDB is reporting compatibility, but fixes are often documented there as well.
  * This site might be helpful even if you're running a non-Steam copy of a game found on Steam, although some workarounds might be Proton-specific (i.e. might not work with Wine in general).
  * You might find compatibility reports and fixes for native Linux games, but the site's original purpose was Proton compatibility reporting. In light of this and given Proton's ease of use, a ProtonDB user's first suggestion for a troublesome Linux port might just be to use the Windows version instead.
* Issues and workarounds specifically pertaining to Steam games for Windows may also be found in the Proton issue tracker ([`https://github.com/ValveSoftware/Proton/issues`](https://github.com/ValveSoftware/Proton/issues)).
* If you're trying to run a non-Steam game for Windows, you can try the Wine Application Database ([`https://appdb.winehq.org/`](https://appdb.winehq.org/)).
* It should go without saying that various forums (on Steam, GOG, etc.) can also be a useful resource.
* PC Gaming Wiki ([`https://www.pcgamingwiki.com/`](https://www.pcgamingwiki.com/)) might also be worth checking, but it documents relatively few fixes for Linux, unfortunately.

If none of the documented issues match your own, you might find yourself in a position to write your own compatibility report, create your own forum thread to ask for help, or even submit your own bug report to some project if you know where to send it. This can be frustrating, as you might not get an answer right away, but it may help you and others in the long run — that is, if you've provided more information than simply "doesn't work".

## Getting Logging
Sometimes, you try to run a game and it just doesn't run. This, unfortunately, often leads to the kind of bug report or cry for help that nobody wants to read:

>I tried running it... and nothing happened!

While this might be an accurate description of what you saw on the screen, it's not helpful to anyone. Something happened, and your first order of business is to find out what it was. This usually means getting some kind of logging or output from whatever you were trying to run.

The primary purpose of this short guide is not to tell you how to interpret whatever errors come out. Some common errors are discussed after this section on gathering logs, but outside of a few easy-to-fix cases, it's likely that you'll be taking this logging to someone else who can help you figure out what it means. But you'll still need to get the logging because it's almost guaranteed that nobody can help you with "and nothing happened". If you don't come with logging, they'll ask for it.

### From the Command Line
This section pertains primarily to native Linux games.

If you've installed a game, and double-clicking on the executable or running it from the menu/desktop shortcut doesn't seem to do anything, try running the game from the command line. While it may appear that a game has failed silently because it didn't generate any pop-up dialogs, it probably did output some kind of error, and the terminal will allow you to see it.

#### With an Executable
If what you already tried was simply double-clicking directly on the game's executable binary or runner script in your file manager, then just enter that same file path into a terminal.

Depending on your system configuration, you may be able to click and drag the executable from your file manager into a terminal window in order to paste the file path.

You may also be able to right-click the file manager and select "Open in Terminal" (or similar) to open the game's directory in your terminal, at which point you could run the main executable or script by entering the relative path starting with `./` (where `.` is a reference to the terminal's current working directory). In other words, if you've already opened the directory containing a `start.sh` in your terminal, you can enter `./start.sh` to run it.

Only if the game's directory is included in your `$PATH` value can you get away with just typing the executable name by itself with no slashes.

#### With a Shortcut
You might also have a menu shortcut or desktop shortcut, which will come in handy in a few circumstances: if you don't actually know where the game is installed, if you found where it's installed but don't know which executable to run, or if the shortcut actually runs the executable with some specific arguments that you need.

Depending on your system, you might be able to see what command a shortcut is running by right-clicking it and selecting "Properties" (or similar). If you can find the `.desktop` file defining the shortcut, you can also just open up the file in a text editor. Menu and desktop shortcuts on Linux are [desktop entry](desktop-entries.md) files. The string after `Exec=` is the command that the shortcut runs, and the path specified by `Path=` (if it exists) is the directory from which the command should be executed.

Depending on your distribution, you can probably run the shortcut using the `gtk-launch` command, with the desktop entry file name (with or without the `.desktop` extension) as an argument. (This will start the game or program as a background process but you should still see some output.)

Otherwise, you can just use `cd` to go to the location specified by the `Path=` line (which you should put in quotes if it has spaces or other weird characters), and then enter what comes after `Exec=` (without adding any quotes). If the `Exec=` line contains `%F`, `%f`, `%U`, or `%u`, then you can just omit that for now; these special strings represent files or URIs passed as arguments to the executable. Just clicking the shortcut generally shouldn't result in any arguments being passed, and thus you shouldn't need to worry about this if what you're trying to reproduce at the command line is the simple "click the shortcut" behavior.

#### Writing to a File
In general, running the game from a terminal will reveal whatever gets logged to the `stdout` and `stderr` streams. If you want to capture this output to a file, say `~/output.txt`, you can append `> ~/output.txt 2>&1` to whatever command you're running. If you really care to separate the `stdout` and `stderr` streams (typically containing normal output and errors respectively), you can append something like `> ~/stdout.txt 2> ~/stderr.txt` instead. If you need to see the output in real time as well as saving it to a file, you can use `tee`; capturing both streams to the same `~/output.txt` can be done by appending `2>&1 | tee ~/output.txt` to your command.

Do note that redirecting output to a file as shown above will erase the contents of that output file if it already exists, and will do so without asking for confirmation. If you want to append to files instead of overwriting them, you can use `>> ~/output.txt 2>&1` or `>> ~/stdout.txt 2>> ~/stderr.txt` or `2>&1 | tee -a ~/output.txt`, but combining the output from multiple runs will likely just cause confusion. It's probably best to change the output filename if you don't want to overwrite an existing file.

### From Wine
If you're running `wine` without the help of a graphical front-end (e.g. Steam, Bottles, or Lutris), then you're probably already using the command line and thus have already seen the kind of output that you could get from the advice given in the previous section.

The thing about Wine is that it generates more logging than you'll see at the terminal by default. The environment variable `WINEDEBUG` can be used to enable additional debug output, which might be useful to include in bug reports or other requests for help. For example, `WINEDEBUG=warn+all` will enable all warnings. Like all environment variables, this would be put before your `wine` command, e.g.
```bash
WINEDEBUG=warn+all wine game.exe
```
The output may be quite large, so redirecting the output to a file (as explained above) is advisable.

For more information on `WINEDEBUG` (though it's probably more in-depth than you'll like if you're reading this page), see: [`https://gitlab.winehq.org/wine/wine/-/wikis/Debug-Channels`](https://gitlab.winehq.org/wine/wine/-/wikis/Debug-Channels)

### From Steam
Running a game's executable directly from the command line isn't very helpful if what you actually want to troubleshoot is running the game from Steam, which will generally use a runtime environment which differs from what you have at the command line.

You can get some output from games executed through Steam if you launched Steam itself from the command line, but this can be a hassle if you've already got Steam running, because you'll have to shut it down first. Fortunately, we can do what we need through the launch options interface. This can be accessed by right-clicking a game in your library and selecting "Properties..."; you'll find the launch options field in the "General" tab of the window that opens.

#### Native Games
For native Linux games, we can redirect output to a file in the same way as described above — e.g. by appending `> ~/output.txt 2>&1` to your launch options. If your launch options field is empty, then you can just paste that text as-is, or with a different filename if you don't want to clobber an existing `~/output.txt`. If you already have something else in the launch options field, then output redirection will generally go at the very end.

#### With Proton
To get extra logging from Proton, add the environment variable `PROTON_LOG=1` to your launch options. This should go before `%command%`, so:
* if your launch options field is empty, then just set it to `PROTON_LOG=1 %command%`;
* if you already have launch options but there's no `%command%`, then put `PROTON_LOG=1 %command%` at the beginning;
* if your launch options already contain `%command%`, then putting `PROTON_LOG=1` at the beginning is most likely correct.

This `PROTON_LOG=1` environment variable will tell Proton to write a log file which, by default, will be found in your home directory with a name of the form `steam-*.log`. For more information, see: [`https://github.com/ValveSoftware/Proton?tab=readme-ov-file#runtime-config-options`](https://github.com/ValveSoftware/Proton?tab=readme-ov-file#runtime-config-options)

### From Bottles
Bottles, as a graphical front-end for Wine, obfuscates what's going on in the output streams by default. You can, however, make it display a terminal. Before using your bottle's '"Run Executable" button, click the gear button next to it and check the "Run in Terminal" box. Alternatively, if your game already has a shortcut in the bottle's "Programs" list, click the menu button to the right of the shortcut's play button, and then click the button with the terminal icon.

Given that Bottles uses Wine, the `WINEDEBUG` environment variable (described above) can be used. Bottles also has a launch options field which functions approximately like that of Steam (also described above), so you can enable all warnings from Wine by putting `WINEDEBUG=warn+all %command%` in the launch options. However, if you want to try output redirection with Bottles launch options, be aware that the Bottles Flatpak will generally not be allowed to write to your home directory (as in previous output redirection examples) by default.

Of course, you can also run Bottles itself from the command line (as `flatpak run com.usebottles.bottles`), and any errors encountered in running games should show up there.

## Common Errors

### Permission Denied
If you get a permission error, then you probably need to add execute permission to the game's main executable. (If you're double-clicking a binary with no execute permission then your file manager is probably telling you that it doesn't know how to open the file, but if you're double-clicking a shell script that runs a binary which is erroneously lacking execute permission then you might see nothing happen.)

You should be able to see if a file has execute permission, and make it so if not, by right-clicking the file and opening its properties. Otherwise, you can open a terminal and use `chmod`, e.g. `chmod +x gameExecutable`.

The game could also be lacking permission to write to some directory, so the file name that comes with the "permission denied" error is important.

### Cannot Open Shared Object File
If you get an error of the form
```
gameExecutable: error while loading shared libraries: libSomething.so.x.y.z: cannot open shared object file: No such file or directory
```
then the game is failing to find some library.

Sometimes this can happen because you're not running the game from the correct directory, or because a certain environment variable like `LD_LIBRARY_PATH` or `LD_PRELOAD` isn't set properly. If a game for Linux comes with a shell script (e.g. a `start.sh`), then it should resolve any such issues (boldly assuming no bugs), and you should generally run that script instead of running a binary executable directly.

Other times, a game will depend on some shared library which is neither included with the game nor installed on your system. In some cases, you can use your package manager to install the library it's missing. However, game may also require some dependency which you can't get from your distribution's package repository, because the specific version of that library the game needs is too old. This happens often with older games built with the GameMaker Studio engine, which typically require `libcrypto.so.1.0.0` and `libssl.so.1.0.0`, for example. If you can download copies of these shared object files and then set the environment variable `LD_LIBRARY_PATH` to the location where you saved them, it might get such a game working.

However, the easier solution might be to run the game through Steam, where it can benefit from Steam Linux Runtime which provides many libraries commonly required by native Linux games. (After adding the game to your Steam library with the "Add a Non-Steam Game..." option: open the "Compatibility" tab of the game's "Properties" menu, check the "Force the use of a specific Steam Play compatibility tool" box, and select "Steam Linux Runtime 1.0 (scout)" from the drop-down list.
