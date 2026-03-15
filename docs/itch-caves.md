# Itch.io Game Launch Commands
As of writing, the official [itch app](https://itch.io/app) does not appear to have any built-in way to create a menu or desktop shortcut to an installed game. We can, of course, [make our own](desktop-entries.md), and directly invoking a game's executable in our custom shortcut may be sufficient in most cases. However, if we want a shortcut that runs a game _through_ the itch app (perhaps to take advantage of its sandboxing features), then creating our own shortcut is not quite as straightforward.

A game shortcut created by Steam will generally run a command of the form `steam steam://rungameid/[...]` where the `[...]` is a placeholder for the Steam game's app ID. It turns out that the itch app uses a similar system, as we can see by importing an installed itch.io game into [Cartridges](https://codeberg.org/kramo/cartridges) which then generates a launch command of the form `xdg-open itch://caves/[...]/launch` where, again, `[...]` is some ID. The problem is that this ID is harder to get than a Steam game's app ID. You can't simply pull it from the game's itch.io store page URL, for example. But you can read it from a database in your itch app's configuration directory.

To read from this database, found at `~/.config/itch/db/butler.db` on my machine, we can install the `sqlite3` command-line interface. (I installed this on Linux Mint by running `sudo apt install sqlite3`.) Once that's done, the itch importer in the Cartridges source code serves as an example of how we can query this database. For the purpose of simply determining each game's `itch://caves/[...]/launch` URL, we can use a simpler query than Cartridges does, but with the same inner join:
```sql
select caves.id, games.title from caves inner join games on caves.game_id = games.id
```
To run that query on `butler.db` and then make a launch command from each row returned:
```bash
sqlite3 ~/.config/itch/db/butler.db \
	'select caves.id, games.title from caves inner join games on caves.game_id = games.id' \
	| sed -E s?'([0-9a-f\-]+)\|'?'xdg-open itch://caves/\1/launch  # '?
```
In each printed launch command, you could also replace `xdg-open` with the path to the `itch` executable (`~/.itch/itch` on my machine).

With a bit more effort, one could write a script that automatically generates menu/desktop shortcuts for itch games, but that can be your homework. I just wanted to document the command to get the "cave" IDs.
