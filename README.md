# PiApps-terminal_bash-edition

[![CodeFactor](https://www.codefactor.io/repository/github/itai-nelken/piapps-terminal_bash-edition/badge)](https://www.codefactor.io/repository/github/itai-nelken/piapps-terminal_bash-edition)

a 100% bash pi-apps for terminal loosely based on [PiAppsTerminalAdvanced](https://github.com/techcoder20/PiAppsTerminalAdvanced) by [@techcoder20](https://github.com/techcoder20/).

## Installation
run the following line in terminal:
```bash
wget -qO- https://raw.githubusercontent.com/Itai-Nelken/PiApps-terminal_bash-edition/main/install.sh | bash
```
that will install pi-apps if it isn't alreday installed as well as removing the script and all its components and then downloading/creating them again.

<details>
  <summary><b>Uninstallation</b></summary>
  
  To uninstall pi-apps terminal bash edition run the following in terminal:
  ```bash
  wget -qO- https://raw.githubusercontent.com/Itai-Nelken/PiApps-terminal_bash-edition/main/uninstall.sh | bash
  ```
  
 </details>

## Usage
`pi-apps [option]`<br>
**Available options:**<br>
`install` - install a app available in pi-apps.<br>
`remove` - uninstall a app installed by pi-apps (`uninstall` also works).<br>
`multi-install` - install multiple apps.<br>
`multi-remove` - uninstall multiple apps (`multi-uninstall` also works).<br>
`list-all` - list all the apps in pi-apps (note that this will also list apps that are not available for your OS).<br>
`list-installed` - list all the apps installed by pi-apps.<br>
`list-uninstalled` - list all the uninstalled apps.<br>
`list-corrupted` - list all the corrupted apps.<br>
`search` - **usage:** `search "search-term"`. search a app available in pi-apps (note that this will show results from the description of the apps as well as their name).<br>
`website` - **usage:** `website "app-name"`. print the website of a app available in pi-apps.<br>
`update` - update all pi-apps components.<br>
`update-apps` - update all pi-apps apps only.<br>
`gui` - launch pi-apps regularly.<br>

if you don't give any option or don't spell a option correctly pi-apps will start regularly.


## To Do:
#### Note that some things marked as done are only on the beta.
- [x] install and uninstall (remove)
- [x] multi-install and multi-uninstall (multi-remove)
- [ ] merge install/uninstall and multi-install/multi-uninstall (respectively): detect if single app or a list of apps provided.
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
