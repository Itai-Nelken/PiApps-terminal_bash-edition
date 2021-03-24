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

#function remove() {
#    #Removing existing /usr/local/bin/pi-apps and script
#    printf "removing existing version of the script..."
#    sudo rm -f /usr/local/bin/pi-apps
#    rm -f "$HOME/pi-apps/pi-apps-terminal-bash-edition.sh"
#    echo "done"
#}
#
#function uninstall-pi-apps() {
#    ~/pi-apps/uninstall
#}

cd "$HOME"
#Removing /usr/local/bin/pi-apps and script
printf "removing the script..."
sudo rm -f /usr/local/bin/pi-apps
rm -f "$HOME/pi-apps/pi-apps-terminal-bash-edition.sh"
echo "done"

#restore original /usr/local/bin/pi-apps
printf "restoring old '/usr/local/bin/pi-apps'..."
echo "#!/bin/bash
$HOME/pi-apps/gui" > ~/pi-apps/pi-apps
sudo mv ~/pi-apps/pi-apps /usr/local/bin/pi-apps || error "Failed to move launcher script to '/usr/local/bin/'!"
sudo chmod +x /usr/local/bin/pi-apps || error "Failed to make launcher script executable!"
echo "done"

#display 'done' message
echo -e "\n\n"
echo -e "${green}${inverted}${bold}uninstallation of pi-apps terminal bash edition succesful!${normal}"
exit 0