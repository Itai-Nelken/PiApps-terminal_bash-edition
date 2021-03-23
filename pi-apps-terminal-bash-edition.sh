#!/bin/bash

#directory variables
PI_APPS_DIR="$HOME/pi-apps"

#text formatting variables
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
light_red="\e[91m"
light_green="\e[92m"
light_yellow="\e[93m"
light_blue="\e[94m"
cyan="\e[36m"
dark_grey_background="\e[100m"
bold="\e[1m"
underline="\e[4m"
inverted="\e[7m"
normal="\e[0m"

function help() {
    echo -e "\n${inverted}${bold}${light_blue}USAGE:${normal}"
    echo '-------'
    echo -e "${underline}${light_green}./pi-apps-terminal-bash-edition.sh [option]${normal}"
    echo -e "\n${inverted}${bold}${light_blue}Available options:${normal}"
    echo '-------------------'
    echo -e "${dark_grey_background}install '[appname]'${normal} - install any app available in pi-apps.\n"
    echo -e "${dark_grey_background}remove '[appname]'${normal} - uninstall any app available in pi-apps.\n"
    echo -e "${dark_grey_background}list-all${normal} - print all apps available in pi-apps.\n"
    echo -e "${dark_grey_background}list-installed${normal} - print all installed apps.\n"
    echo -e "${dark_grey_background}search '[appname]'${normal} - search all apps available in pi-apps (case sensitive).\n"
    echo -e "${dark_grey_background}update-all${normal} - update all pi-apps components.\n"
    echo -e "${dark_grey_background}update${normal} - update all apps.\n"
    echo -e "${dark_grey_background}website '[appname]'${normal} - print the website of any app in pi-apps.\n"
    echo -e "${dark_grey_background}gui${normal} - launch the pi-apps GUI.\n"
    echo '===================='

    echo -e "\n${cyan}${bold}if you don't supply any option or the option you entered is invalid,"   
    echo -e "pi-apps will start with the GUI${normal}" 
}

function get-website() { 
    dir="$PI_APPS_DIR/apps/${1}";
    website="$(cat "${dir}/website")"
}


function list-all() {
    for dir in $PI_APPS_DIR/apps/*/; do
        dirname=$(basename "$dir")
        if [[ "$dirname" != "template" ]]; then
            echo -e "\n${bold}${inverted}${light_blue}$dirname${normal}"
            DESC="${green}$(cat "$dir"/description)${normal}"
            echo -e $DESC
        fi
    done
}

function search() {
    for dir in $PI_APPS_DIR/apps/*/; do
        dirname=$(basename "$dir")
        if [[ "$dirname" != "template" ]]; then
            #echo $dirname
		    if [[ $dirname == "*$1*" ]]; then
				#echo "FIRST"
				echo -e "${bold}${inverted}${light_blue}$dirname${normal}"
				DESC="$(cat $PI_APPS_DIR/apps/$dirname/description)"
                echo -e "${green}$DESC${normal}"
	    	elif grep -q "$1" "$PI_APPS_DIR/apps/$dirname/description" ; then
				#echo "SECOND"
                echo -e "${bold}${inverted}${light_blue}$dirname${normal}"
				DESC="$(cat $PI_APPS_DIR/apps/$dirname/description)"
                echo -e "${green}$DESC${normal}"
   	    	fi
        fi
    done

}

if [[ "$1" == "install" ]]; then
    #install apps
    $PI_APPS_DIR/manage install "$2"

elif [[ "$1" == "remove" ]]; then
    #uninstall apps
    $PI_APPS_DIR/manage uninstall "$2"

elif [[ "$1" == "list-installed" ]]; then
    #list all installed apps
    echo -e "${light_yellow}function not implemented yet.${normal}"


elif [[ "$1" == "list-all" ]]; then
    #list all apps
    list-all

elif [[ "$1" == "search" ]]; then
    #search a app
    search $2

elif [[ "$1" == "update-all" ]]; then
    #update all pi-apps
    $PI_APPS_DIR/updater

elif [[ "$1" == "update" ]]; then
    #update all apps
    $PI_APPS_DIR/manage update-all

elif [[ "$1" == "website" ]]; then
    #print the website of a app
    get-website "$2"
    echo -e "${cyan}${inverted}$2's website:${normal}"
    echo -e "${bold}$website${normal}"

elif [[ "$1" == "gui" ]]; then
    #open pi-apps regularly
    $PI_APPS_DIR/gui
    
elif [[ "$1" == "help" ]]; then
    #print help
    help
else
    $PI_APPS_DIR/gui
fi
