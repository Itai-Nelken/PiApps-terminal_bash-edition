#!/bin/bash

#add option to download beta
BETA="yes"

red="\e[31m"
green="\e[32m"
inverted="\e[7m"
normal="\e[0m"
bold="\e[1m"

function error() {
  echo -e "${red}$1${normal}"
  exit 1
}

function warning() {
  echo -e "${red}$1${normal}"
  sleep 1
}

cd "$HOME"

if [[ "$BETA" == "yes" ]]; then
  #install beta or stable?  
  while [ "$1" != "" ]; do
    case $1 in
      beta)
        VER="beta"
        ;;
      main)
        VER="main"
        ;;
      *)
        warning "Unknown version '$1'! using the default version (stable)."
        VER="main"
        ;;
    esac
    shift
  done
fi

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

#Removing existing /usr/local/bin/pi-apps and script
printf "removing existing version of the script..."
sudo rm -f /usr/local/bin/pi-apps
rm -f "$HOME/pi-apps/pi-apps-terminal-bash-edition.sh"
echo "done"
#Download script
printf "Downloading script..."
if [[ "$VER" == "main" ]]; then
  wget -q https://raw.githubusercontent.com/Itai-Nelken/PiApps-terminal_bash-edition/main/pi-apps-terminal-bash-edition.sh -O $HOME/pi-apps/pi-apps-terminal-bash-edition.sh || error "Failed to download pi-apps terminal bash edition script!"
elif [[ "$VER" == "beta" ]]; then
  wget -q https://raw.githubusercontent.com/Itai-Nelken/PiApps-terminal_bash-edition/main/pi-apps_terminal_bash_beta.sh -O $HOME/pi-apps/pi-apps-terminal-bash-edition.sh || error "Failed to download pi-apps terminal bash edition script!"
else
  wget -q https://raw.githubusercontent.com/Itai-Nelken/PiApps-terminal_bash-edition/main/pi-apps-terminal-bash-edition.sh -O $HOME/pi-apps/pi-apps-terminal-bash-edition.sh || error "Failed to download pi-apps terminal bash edition script!"
fi
echo "done"
#create launcher script
printf "creating launcher script..."
echo '#!/bin/bash
#/home/pi/pi-apps/gui
bash ~/pi-apps/pi-apps-terminal-bash-edition.sh "$@"' > ~/pi-apps/pi-apps || error "Failed to create pi-apps/pi-apps terminal launcher script!"
sudo mv ~/pi-apps/pi-apps /usr/local/bin/pi-apps || error "Failed to move launcher script to '/usr/local/bin/'!"
sudo chmod +x /usr/local/bin/pi-apps || error "Failed to make launcher script executable!"
echo "done"
echo -e "\n\n"
echo -e "${bold}${green}run 'pi-apps help' for a list of all commands.${normal}"
echo -e "${green}${inverted}${bold}installation of pi-apps terminal bash edition succesful!${normal}"
exit 0