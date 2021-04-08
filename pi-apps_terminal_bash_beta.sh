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

function error() {
  echo -e "${red}${bold}[!] ${normal}${red}$1${normal}"
  exit 1
}

function about() {
    echo -e '
    ####################################
    # Pi-Apps terminal - bash edition  #
    # -------------------------------- #
    #      By Itai-Nelken | 2021       #
    # ================================ #
    #        Pi-Apps by Botspot        #
    ####################################
    '
}

function help() {
    echo -e "\n${inverted}${bold}${light_blue}USAGE:${normal}"
    echo '-------'
    #echo -e "${underline}${light_green}./pi-apps-terminal-bash-edition.sh [option]${normal}"
    echo -e "${underline}${light_green}pi-apps [option]${normal}"
    echo -e "\n${inverted}${bold}${light_blue}Available options:${normal}"
    echo '-------------------'
    echo -e "${dark_grey_background}install '[appname]'${normal} - install any app available in pi-apps.\n"
    echo -e "${dark_grey_background}remove '[appname]'${normal} - uninstall any app available in pi-apps you can also use ${dark_grey_background}uninstall${normal}.\n"
    echo -e "${dark_grey_background}list-all${normal} - print all apps available in pi-apps.\n"
    echo -e "${dark_grey_background}list-installed${normal} - print all installed apps.\n"
    echo -e "${dark_grey_background}list-uninstalled${normal} - print all uninstalled apps.\n"
    echo -e "${dark_grey_background}list-corrupted${normal} - print all apps with the corrupted statu (meaning they failed to install/uninstall).\n"
    echo -e "${dark_grey_background}search '[appname]'${normal} - search all apps available in pi-apps (case sensitive).\n"
    echo -e "${dark_grey_background}update-all${normal} - update all pi-apps components.\n"
    echo -e "${dark_grey_background}update${normal} - update all apps.\n"
    echo -e "${dark_grey_background}website '[appname]'${normal} - print the website of any app in pi-apps.\n"
    echo -e "${dark_grey_background}gui${normal} - launch the pi-apps normally.\n"
    echo -e "${dark_grey_background}help${normal} - show this help."
    echo '===================='

    echo -e "\n${cyan}${bold}if you don't supply any option pi-apps will start normally.${normal}"   
}

function get-website() { 
    dir="$PI_APPS_DIR/apps/${1}";
    website="$(cat "${dir}/website")" || website_error=1
}


function list-all() {
    for dir in $PI_APPS_DIR/apps/*/; do
        dirname=$(basename "$dir")
        if [[ "$dirname" != "template" ]]; then
            if [[ -f $PI_APPS_DIR/apps/$dirname/install-32 ]] || [[ -f $PI_APPS_DIR/apps/$dirname/install ]]; then
                echo -e "\n${bold}${inverted}${light_blue}$dirname${normal}"
                DESC="${green}$(cat "$dir"/description)${normal}"
                echo -e $DESC
            fi
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
				DESC="$(cat "$PI_APPS_DIR/apps/$dirname/description")"
                echo -e "${green}$DESC${normal}"
	    	elif grep -q "$1" "$PI_APPS_DIR/apps/$dirname/description" ; then
				#echo "SECOND"
                echo -e "${bold}${inverted}${light_blue}$dirname${normal}"
				DESC="$(cat "$PI_APPS_DIR/apps/$dirname/description")"
                echo -e "${green}$DESC${normal}"
   	    	fi
        fi
    done

}

#check if '~/pi-apps/api' exists
#if [[ ! -f "$HOME/pi-apps/api" ]]; then
#    error "The pi-apps \"api\" script doesn't exist!\nPlease update pi-apps with '~/pi-apps/updater'."
#fi

#run the pi-apps api script to get its functions
#source $PI_APPS_DIR/api &>/dev/null

while [ "$1" != "" ]; do
    case $1 in
    -h | --help | -help | help)
        #show the help
        help
        exit 0
        ;;
    install)
        #install apps
        $PI_APPS_DIR/manage install "$2"
        exit $?
        ;;
    remove | uninstall)
        #uninstall apps
        $PI_APPS_DIR/manage uninstall "$2"
        exit $?
        ;;
    list-installed)
        #list all the installed apps
        #list_apps installed
        ls "$PI_APPS_DIR/apps" | GREP_COLORS='ms=1;34' grep --color=always -x "$(grep -rx 'installed' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!' | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')"
        exit 0
        ;;
    list-uninstalled)
        #list all the uninstalled apps
        #list_apps uninstalled
        ls $PI_APPS_DIR | grep --color=always -x "$(grep -rx 'uninstalled' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!' | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')"
        ls $PI_APPS_DIR | grep --color=always -vx "$(ls "${DIRECTORY}/data/status" | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')"
        exit 0
        ;;
    list-corrupted)
        #list all the corrupted apps
        #list_apps corrupted
        ls $PI_APPS_DIR/apps | grep --color=always -x "$(grep -rx 'corrupted' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!' | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')"
        exit 0
        ;;
    list-all)
        #list all the apps
        list-all
        exit 0
        ;;
    search)
        #search apps
        search $2
        exit 0
        ;;
    update-all)
        #update all pi-apps
        $PI_APPS_DIR/updater
        exit $?
        ;;
    update)
        #update all apps
        $PI_APPS_DIR/manage update-all
        exit $?
        ;;
    website)
        #print the website of a app
        get-website "$2" &>/dev/null
        if [[ "$website_error" == "1" ]]; then
            echo -e "${red}${bold}ERROR:${normal}${red} There is no app called ${light_red}'$2'${red}!${normal}"
            exit 1
        else
            echo -e "${cyan}${inverted}$2's website:${normal}"
            echo -e "${bold}$website${normal}"
            exit 0
        fi
        ;;
    gui)
        #open pi-apps regularly
        $PI_APPS_DIR/gui
        exit $?
        ;;
    -v | --version | version | about | --about)
        #display about
        about
        exit 0
        ;;
    *)
        error "Unknown option '${light_blue}$1${red}'! run ${normal}${dark_grey_background}pi-apps help${normal}${red} to see all options."
        ;;
    esac
    shift
done
$PI_APPS_DIR/gui
exit $?
