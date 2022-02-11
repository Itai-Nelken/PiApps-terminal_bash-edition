# PiApps-terminal_bash-edition

[![CodeFactor](https://www.codefactor.io/repository/github/itai-nelken/piapps-terminal_bash-edition/badge)](https://www.codefactor.io/repository/github/itai-nelken/piapps-terminal_bash-edition)

A 100% bash pi-apps for terminal loosely based on [PiAppsTerminalAdvanced](https://github.com/techcoder20/PiAppsTerminalAdvanced) by [@techcoder20](https://github.com/techcoder20/).

## Installation

[![badge](https://github.com/Botspot/pi-apps/blob/master/icons/badge.png?raw=true)](https://github.com/Botspot/pi-apps)  

Run the following line in terminal:
```bash
wget -qO- https://raw.githubusercontent.com/Itai-Nelken/PiApps-terminal_bash-edition/main/install.sh | bash
```
That will install pi-apps if it isn't already installed, as well as removing the script and all its components and then downloading/creating them again.

<details>
  <summary><b>Uninstallation</b></summary>
  
  To uninstall pi-apps terminal bash edition, run the following in terminal:
  ```bash
  wget -qO- https://raw.githubusercontent.com/Itai-Nelken/PiApps-terminal_bash-edition/main/uninstall.sh | bash
  ```
  
 </details>

## Usage

`pi-apps [option] [arguments]`

### Available options:

`install [app]` - install any app available in pi-apps.

`uninstall/remove [app]` - uninstall any app available in pi-apps.

`reinstall [app]` - reinstall any app available in pi-apps.

`list-all [-d|--description]` - print all apps available in pi-apps.

`list-installed [-d|--description]` - print all installed apps.

`list-uninstalled [-d|--description]` - print all uninstalled apps.

`list-corrupted [-d|--description]` - print all apps failed to install/uninstall (are corrupted).

`status [app]` - print the status of a app in pi-apps.

`search [query]` - search all apps available in pi-apps.

`website [app]` - print the link to the website of any app in pi-apps.

`update [-y|--yes]` - update all apps and pi-apps itself.

`info/details [app]` - print the information of any app in pi-apps.

`gui` - launch pi-apps normally.

`help` - show help message.


**If you don't supply any option, pi-apps will start normally.**


## To Do:
#### Note that some things marked as done are only on the beta.
- [x] install and uninstall (remove)
- [x] multi-install and multi-uninstall (multi-remove)
- [x] merge install/uninstall and multi-install/multi-uninstall (respectively): detect if single app or a list of apps provided.
- [x] list-all
- [x] list-installed
- [x] list-uninstalled (thanks to the new pi-apps `api` script).
- [x] list-corrupted (thanks to the new pi-apps `api` script).
- [x] search
- [x] update-all
- [x] update
- [x] website (including apps with a space in their name)
- [x] gui (default pi-apps one)
- [x] help
- [x] write the README
- [ ] updater for the script.
- [x] when running `list-all`, only list all the apps that work for your architecture.
- [x] search only the apps that are available for your architecture (using pi-apps's 'api' script).
- [x] `status` option. USAGE: `pi-apps status [app]` OUTPUT: `[app] - [status]` status can be: `installed`, `uninstalled`, and `corrupted`.
