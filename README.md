# PiApps-terminal_bash-edition
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
`list-all` - list all the apps in pi-apps (note that this will also list apps that are not available for your OS).<br>
`list-installed` - list all the apps installed by pi-apps.<br>
`search` - **usage:** `search "search-term"`. search a app available in pi-apps (note that this will show results from the description of the apps as well as their name).<br>
`website` - **usage:** `website "app-name"`. print the website of a app available in pi-apps.<br>
`update` - update all apps in pi-apps.<br>
`update-all` - update all pi-apps components.<br>
`gui` - launch pi-apps regularly.<br>

if you don't give any option or don't spell a option correctly pi-apps will start regularly.


## To Do
- [x] install and uninstall (remove)
- [x] list-all
- [x] list-installed
- [x] search
- [x] update-all
- [x] update
- [x] website (including apps with a space in their name)
- [x] gui (default pi-apps one)
- [x] help
- [x] write the README
- [ ] updater for the script.
- [x] when running `list-all`, only list all the apps that work for your architecture.
- [ ] search only the apps that are available for your architecture.
- [ ] `status` option. USAGE: `pi-apps status [app]` OUTPUT: `[app] - [status]` status can be: `installed`, `uninstalled`, and `corrupted`.
