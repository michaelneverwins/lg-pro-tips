#!/usr/bin/python3
"""Shows configuration of installed Steam games.

Expected output includes the default Steam Play compatibility tool (as
selected in Steam's global settings) as well as, for each installed game,
the compatibility tool in use (if it differs from the default) and the
launch options applied (if any).

I wanted to write this in Bash, but I discovered that I'm not enough of a
Bash wizard to do that, so I gave up. Python 3 is required.

This script operates on a few assumptions:
* that the Linux version of Steam is installed;
* that Steam's root folder is in the location specified by ``ROOT``;
* that, within Steam's ``userdata`` folder, the most recently modified item
  is the folder containing the data of the user running the script (i.e.
  that if any other user folders or extraneous files exist then they are
  older);
* that Steam's configuration files and directory structure are as they were
  when this script was last modified.

This script comes with no warranty of any kind. Use it at your own risk.
"""

import json
import os
import pathlib
import re

HOME = pathlib.Path.home()
ROOT = os.path.join(HOME, ".steam", "root")


def vdf_to_json(text: str) -> str:
    """Convert the contents of a ``.vdf`` or ``.acf`` file to JSON.

    Converting these files to JSON format surely isn't the most efficient
    means of parsing them into Python dictionaries, but I found it to be
    convenient. We can just add some punctuation and then let Python's JSON
    module do the actual parsing work.
    """
    # Add colons after keys mapping to scalar values:
    text = re.sub(
        r'^\s*"([^"]+)"\s+"(|.*?[^\\])"$',
        r'"\1": "\2"',
        text,
        flags=(re.MULTILINE | re.DOTALL),
    )
    # Add colons after keys mapping to maps:
    text = re.sub(r'^\s*"([^"]+)"\s*{$', r'"\1": {', text, flags=re.MULTILINE)
    # Add commas after values followed by keys:
    text = re.sub(r'(["}])(?=$\s+^\s*")', r"\1,", text, flags=re.MULTILINE)
    # Remove line breaks and tabs:
    text = re.sub(r"\s+", r" ", text, flags=re.MULTILINE)
    # Put everything between brackets:
    return text.join("{}")


def get_compatibility_tool_mapping() -> dict:
    """Get the mapping of app IDs to compatibility tools.

    Note: In ``config.vdf``, each value in the compatibility tool mapping
    is actually a nested mapping with three keys: ``name``, ``config``, and
    ``Priority``. Only the ``name`` value is used by this function. The
    purpose of the ``config`` value is unclear as it always seems to be an
    empty string, while the ``Priority`` value seems to be used only to
    give game-specific compatibility tool selections higher priority than
    the default compatibility tool.
    """
    with open(
        os.path.join(HOME, ".steam", "root", "config", "config.vdf"), "rt"
    ) as f:
        config = json.loads(vdf_to_json(f.read()))

    mapping = config["InstallConfigStore"]["Software"]["Valve"]["Steam"][
        "CompatToolMapping"
    ]
    return {app_id: tool["name"] for app_id, tool in mapping.items()}


def get_launch_option_mapping() -> dict:
    """Get the mapping of app IDs to launch options.

    This requires reading ``localconfig.vdf`` from a user data directory,
    of which there may be more than one, so the most recently modified user
    data directory is used.
    """
    user_data = os.path.join(HOME, ".steam", "root", "userdata")
    user_id = sorted(
        os.listdir(user_data),
        key=lambda basename: os.path.getmtime(
            os.path.join(user_data, basename)
        ),
    )[-1]

    with open(
        os.path.join(user_data, user_id, "config", "localconfig.vdf"), "rt"
    ) as f:
        config = json.loads(vdf_to_json(f.read()))

    apps = config["UserLocalConfigStore"]["Software"]["Valve"]["Steam"]["Apps"]
    launch_option_mapping = {}
    for app_id, app_info in apps.items():
        try:
            launch_option_mapping[app_id] = app_info["LaunchOptions"]
        except KeyError:
            pass
    return launch_option_mapping


def get_installed_apps() -> list:
    """Get the list of app IDs of currently installed games."""
    installed_app_ids = []
    for name in os.listdir(os.path.join(ROOT, "steamapps")):
        try:
            installed_app_ids.append(
                re.match(r"appmanifest_(\d+).acf", name)[1]
            )
        except TypeError:
            pass
    return installed_app_ids


def get_app_info(app_id: str) -> tuple:
    """Given an app ID, get required app information from the app manifest.

    The result is two values: the game's title and a Boolean indicating whether
    the game is Linux-native. To determine the latter, it is assumed that the
    ``platform_override_source`` value in the app manifest will be either blank
    or non-existent if and only if a game runs natively on Linux.
    """
    with open(
        os.path.join(ROOT, "steamapps", f"appmanifest_{app_id}.acf"), "rt"
    ) as f:
        app_state = json.loads(vdf_to_json(f.read()))["AppState"]
        return app_state["name"], not app_state["UserConfig"].get(
            "platform_override_source"
        )


def format_name(name: str) -> str:
    """Get a more human-readable name for the given compatibility tool.

    For input starting with ``proton_``, this function assumes that the
    first character following the underscore is the major version number
    and that any subsequent characters comprise the minor version number.
    This particular implementation will presumably stop working when Proton
    10 is released.

    For all other input, this function simply returns the given string with
    title-like capitalization.
    """
    if name.startswith("proton_"):
        # Assume "proton_XYZ" means "Proton X.YZ".
        version = name.split("_", 1)[1]
        return f"Proton {version[0]}.{version[1:] or '0'}"
    else:
        # Apply title capitalization to all other names, but preserve existing
        # upper-case characters. Note that "A" < "a", etc., hence the `min`.
        return "".join(min(pair) for pair in zip(name.title(), name))


def _main():
    compat_tool_mapping = get_compatibility_tool_mapping()
    # App ID "0" appears to denote the global default compatibility tool.
    default_compat_tool = compat_tool_mapping.pop("0", None) or "N/A"
    print(f"Default compatibility tool: {format_name(default_compat_tool)}")
    launch_option_mapping = get_launch_option_mapping()

    for app_id in get_installed_apps():
        compat_tool = compat_tool_mapping.get(app_id)
        launch_options = launch_option_mapping.get(app_id)
        if compat_tool or launch_options:
            title, is_native = get_app_info(app_id)
            print()
            print(f"{title} ({app_id})")
            if compat_tool:
                compat_tool = format_name(compat_tool)
            else:
                compat_tool = "N/A" if is_native else "Default"
            print(f"\tCompatibility Tool: {compat_tool}")
            if launch_options:
                print(f"\tLaunch Options: {launch_options}")


if __name__ == "__main__":
    _main()
