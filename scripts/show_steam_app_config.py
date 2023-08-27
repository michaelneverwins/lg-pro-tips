#!/usr/bin/python3
"""Shows configuration of installed Steam apps.

Expected output includes the default Steam Play compatibility tool (as
selected in Steam's global settings) as well as, for each installed app,
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

import argparse
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
    ``priority``. Only the ``name`` value is used by this function. The
    purpose of the ``config`` value is unclear as it always seems to be an
    empty string, while the ``priority`` value seems to be used only to
    give app-specific compatibility tool selections higher priority than
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


def get_user_id() -> str:
    """Get the user ID.

    It is assumed that the most recently modified user data folder is the
    correct one.
    """
    user_data = os.path.join(HOME, ".steam", "root", "userdata")
    user_id = sorted(
        os.listdir(user_data),
        key=lambda basename: os.path.getmtime(
            os.path.join(user_data, basename)
        ),
    )[-1]
    return user_id


def _try_keys(dictionary, keys):
    for k in keys:
        try:
            return dictionary[k]
        except KeyError:
            continue
    else:
        raise KeyError("|".join(keys))


def get_launch_option_mapping(user_id: str) -> dict:
    """Get the mapping of app IDs to launch options."""
    with open(
        os.path.join(
            HOME,
            ".steam",
            "root",
            "userdata",
            user_id,
            "config",
            "localconfig.vdf",
        ),
        "rt",
    ) as f:
        config = json.loads(vdf_to_json(f.read()))

    apps = _try_keys(
        config["UserLocalConfigStore"]["Software"]["Valve"]["Steam"],
        # The correct key was "Apps" when I wrote this script, and then it
        # changed to "apps" and the script broke. Now I don't trust it to stay
        # lower-case, so I'll just try both. If this happens again, maybe I'll
        # write a case-insensitive dictionary class or something.
        ("Apps", "apps"),
    )
    launch_option_mapping = {}
    for app_id, app_info in apps.items():
        try:
            launch_option_mapping[app_id] = app_info["LaunchOptions"]
        except KeyError:
            pass
    return launch_option_mapping


def get_platform_override_mapping(user_id: str) -> dict:
    """Get the mapping of app IDs to platform override information."""
    with open(
        os.path.join(
            HOME, ".steam", "root", "userdata", user_id, "config", "compat.vdf"
        ),
        "rt",
    ) as f:
        config = json.loads(vdf_to_json(f.read()))
    return config["platform_overrides"]


def get_installed_apps() -> list:
    """Get the list of app IDs of currently installed apps."""
    installed_app_ids = []
    for name in os.listdir(os.path.join(ROOT, "steamapps")):
        try:
            installed_app_ids.append(
                re.match(r"appmanifest_(\d+).acf", name)[1]
            )
        except TypeError:
            pass
    return installed_app_ids


def get_app_name(app_id: str) -> str:
    """Gets the name associated with the given app ID."""
    with open(
        os.path.join(ROOT, "steamapps", f"appmanifest_{app_id}.acf"), "rt"
    ) as f:
        return json.loads(vdf_to_json(f.read()))["AppState"]["name"]


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
        version = name.split("_", 1)[1]
        if version[0].isdigit():
            # Assume "proton_XYZ" means "Proton X.YZ".
            return f"Proton {version[0]}.{version[1:] or '0'}"
        else:
            return f"Proton {version.title()}"
    else:
        # Apply title capitalization to all other names, but preserve existing
        # upper-case characters. Note that "A" < "a", etc., hence the `min`.
        return "".join(min(pair) for pair in zip(name.title(), name))


def _main(args):
    compat_tool_mapping = get_compatibility_tool_mapping()
    # App ID "0" appears to denote the global default compatibility tool.
    default_compat_tool = (
        format_name(compat_tool_mapping.pop("0", "")) or "N/A"
    )
    print(f"Default compatibility tool: {default_compat_tool}")
    user_id = get_user_id()
    launch_option_mapping = get_launch_option_mapping(user_id)
    platform_override_mapping = get_platform_override_mapping(user_id)

    apps_to_check = get_installed_apps()
    if args.apps and not args.title:
        apps_to_check = set(apps_to_check).intersection(args.apps)

    for app_id in sorted(apps_to_check, key=int):
        compat_tool = compat_tool_mapping.get(app_id)
        launch_options = launch_option_mapping.get(app_id, "")
        if compat_tool or launch_options or args.all_apps:
            title = get_app_name(app_id)
            if args.title and args.apps and not any(
                t.lower() in title.lower() for t in args.apps
            ):
                continue
            platform_override = platform_override_mapping.get(app_id)
            print(f"\n{title} ({app_id})")
            compat_tool = (
                format_name(compat_tool)
                if compat_tool
                else ("Default" if args.default_compat else None)
                if platform_override is not None and platform_override["dest"]
                else ("N/A" if args.no_compat else None)
            )
            if compat_tool:
                print(f"\tCompatibility Tool: {compat_tool}")
            if launch_options or args.empty_launch_options:
                print(f"\tLaunch Options: {launch_options}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            "Shows compatibility tools and launch options currently in use by "
            "Steam apps."
        )
    )
    parser.add_argument(
        "-a",
        "--all-apps",
        action="store_true",
        help=(
            "Show all apps (including those without launch options or "
            "compatibility tool overrides)"
        ),
    )
    parser.add_argument(
        "-d",
        "--default-compat",
        action="store_true",
        help="Explicitly show which apps use the default compatibility tool",
    )
    parser.add_argument(
        "-n",
        "--no-compat",
        action="store_true",
        help="Explicitly show which apps don't use a compatibility tool",
    )
    parser.add_argument(
        "-e",
        "--empty-launch-options",
        action="store_true",
        help="Explicitly print no launch options where none are in use",
    )
    parser.add_argument(
        "-t",
        "--title",
        action="store_true",
        help=(
            "Positional arguments are game titles, not app IDs (enabled "
            "automatically if non-numerical positional arguments are given)"
        ),
    )
    parser.add_argument(
        "apps",
        metavar="APP",
        nargs="*",
        help="App IDs or game titles"
    )
    args = parser.parse_args()
    args.all_apps = args.all_apps or bool(args.apps)
    args.title = args.title or not all(a.isdigit() for a in args.apps)
    _main(args)
