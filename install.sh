#!/bin/bash

red="\e[31m"
green="\e[32m"
inverted="\e[7m"
normal="\e[0m"
bold="\e[1m"

function error() {
  echo -e "${red}$1${normal}"
  exit 1
}

cd "$HOME"

if [[ ! -d $HOME/pi-apps ]]; then
echo "installing pi-apps..."
    sudo apt update || error "Failed to run 'apt update'!"
    sudo apt install -y yad || error "Failed to install YAD!"
    #remove annoying YAD icon browser launcher
    sudo rm -f /usr/share/applications/yad-icon-browser.desktop
    wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash || error "Failed to install pi-apps!"
else
    echo "pi-apps is already installed..."
fi

#Removing existing /usr/local/bin/pi-apps
sudo rm -f /usr/local/bin/pi-apps
#Download script
echo "Downloading script..."
wget https://raw.githubusercontent.com/Itai-Nelken/PiApps-terminal_bash-edition/main/pi-apps-terminal-bash-edition.sh -O $HOME/pi-apps/pi-apps-terminal-bash-edition.sh || error "Failed to download pi-apps terminal bash edition script!"
#create launcher script
echo "creating launcher script..."
echo '#!/bin/bash
#/home/pi/pi-apps/gui
bash ~/pi-apps/pi-apps-terminal-bash-edition.sh "$@"' > ~/pi-apps/pi-apps || error "Failed to create pi-apps/pi-apps terminal launcher script!"
sudo mv ~/pi-apps/pi-apps /usr/local/bin/pi-apps || error "Failed to move launcher script to '/usr/local/bin/'!"
sudo chmod +x /usr/local/bin/pi-apps || error "Failed to make launcher script executable!"

echo -e "${bold}${green}run 'pi-apps help' for a list of all commands.${normal}"
echo -e "${green}${inverted}${bold}installation of pi-apps terminal bash edition succesful!${normal}"
exit 0