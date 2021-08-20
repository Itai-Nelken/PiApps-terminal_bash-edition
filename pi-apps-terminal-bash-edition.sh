#!/bin/bash

### ignore some shellcheck warnings
# shellcheck disable=SC2145,SC2199,SC2034,SC2010,SC2116

#determine if host system is 64 bit arm64 or 32 bit armhf
if [ "$(od -An -t x1 -j 4 -N 1 "$(readlink -f /sbin/init)")" = ' 02' ];then
  arch=64
elif [ "$(od -An -t x1 -j 4 -N 1 "$(readlink -f /sbin/init)")" = ' 01' ];then
  arch=32
else
  echo -e "\e[1mFailed to detect OS CPU architecture! Something is very wrong.\e[0m"
fi

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
white="\e[97m"
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
	echo -e "\n${white}${inverted}${bold}${light_blue}USAGE:${normal}"
	echo '-------'
	#echo -e "${underline}${light_green}./pi-apps-terminal-bash-edition.sh [option]${normal}"
	echo -e "${white}${underline}${light_green}pi-apps [option]${normal}"
	echo -e "\n${white}${inverted}${bold}${light_blue}Available options:${normal}"
	echo '-------------------'
	echo -e "${white}${dark_grey_background}install [appname]${normal}${white} - install any app available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}remove [appname]${normal}${white} - uninstall any app available in pi-apps. you can also use ${dark_grey_background}uninstall${normal}.\n"
	echo -e "${white}${dark_grey_background}multi-install [app1] [app2]${normal}${white} - install multiple apps at the same time.\n"
	echo -e "${white}${dark_grey_background}multi-uninstall [app1] [app2]${normal}${white} - uninstall multiple apps at the same time. you can also use ${dark_grey_background}multi-remove${normal}\n"
	echo -e "${white}${dark_grey_background}reinstall [appname]${normal}${white} - reinstall any app available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}list-all${white}${normal}${white} - print all apps available in pi-apps.\n"
	echo -e "${dark_grey_background}${white}list-installed${normal}${white} - print all installed apps.\n"
	echo -e "${dark_grey_background}${white}list-uninstalled${normal}${white} - print all uninstalled apps.\n"
	echo -e "${dark_grey_background}${white}list-corrupted${normal}${white} - print all apps with the corrupted statu (meaning they failed to install/uninstall).\n"
	echo -e "${dark_grey_background}${white}search '[appname]'${normal}${white} - search all apps available in pi-apps (case sensitive).\n"
	echo -e "${dark_grey_background}${white}update${normal}${white} - update all pi-apps components.\n"
	echo -e "${dark_grey_background}${white}update-apps${normal}${white} - update all pi-apps apps only.\n"
	echo -e "${dark_grey_background}${white}website '[appname]'${normal}${white} - print the website of any app in pi-apps.\n"
	echo -e "${dark_grey_background}${white}gui${normal}${white} - launch the pi-apps normally.\n"
	echo -e "${dark_grey_background}${white}help${normal}${white} - show this help.${normal}"
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
			if [[ -f $PI_APPS_DIR/apps/$dirname/install-${arch} ]] || [[ -f $PI_APPS_DIR/apps/$dirname/install ]]; then
				echo -e "\n${bold}${inverted}${light_blue}$dirname${normal}"
				DESC="${green}$(cat "$dir"/description)${normal}"
				echo -e $DESC
			fi
		fi
	done
}

#function search() {
#	for dir in $PI_APPS_DIR/apps/*/; do
#		dirname=$(basename "$dir")
#		if [[ "$dirname" != "template" ]]; then
#			#echo $dirname
#			if [[ $dirname == "*$1*" ]]; then
#				#echo "FIRST"
#				echo -e "${bold}${inverted}${light_blue}$dirname${normal}"
#				DESC="$(cat "$PI_APPS_DIR/apps/$dirname/description")"
#				echo -e "${green}$DESC${normal}"
#			elif grep -q "$1" "$PI_APPS_DIR/apps/$dirname/description" ; then
#				#echo "SECOND"
#				echo -e "${bold}${inverted}${light_blue}$dirname${normal}"
#				DESC="$(cat "$PI_APPS_DIR/apps/$dirname/description")"
#				echo -e "${green}$DESC${normal}"
#			fi
#		fi
#	done
#
#}

function search() { #search apps using pi-apps's api 'app_search' function
	export DIRECTORY="$PI_APPS_DIR"
		while read -r line; do
			echo -e "${bold}${inverted}${light_blue}$line${normal}"
    		echo -e "${green}$(cat $PI_APPS_DIR/apps/"$line"/description || echo "No description available")${normal}"
		done < <(app_search $1)
}

#check if '~/pi-apps/api' exists
if [[ ! -f "$HOME/pi-apps/api" ]]; then
    error "The pi-apps \"api\" script doesn't exist!\nPlease update pi-apps with '~/pi-apps/updater'."
fi
#run the pi-apps api script to get its functions
source $PI_APPS_DIR/api &>/dev/null

while [ "$1" != "" ]; do
	case $1 in
		-h | --help | -help | help)
			#show the help
			help
			exit 0
		;;
		install)
			shift
			for arg in "$@"; do
				cmdflags+="$arg "
			done
			$PI_APPS_DIR/manage install "$(echo $cmdflags)"
			exit $?
		;;
		multi-install)
			shift
			for arg in "$@"; do
				cmdflags+="$arg\n"
			done
			#remove last \'n'
			args=${cmdflags%\\n}
			#install apps
			$PI_APPS_DIR/manage multi-install "$(echo -e "$args")"
			exit $?
			;;
		remove|uninstall)
			shift
			for arg in "$@"; do
				cmdflags+="$arg "
			done
			$PI_APPS_DIR/manage uninstall "$(echo $cmdflags)"
			exit $?
		;;
		multi-remove | multi-uninstall)
			shift
			for arg in "$@"; do
				cmdflags+="$arg\n"
			done
			args=${cmdflags%\\n}
			#uninstall apps
			$PI_APPS_DIR/manage multi-uninstall "$(echo -e "$args")"
			exit $?
			;;
		reinstall)
			shift
			for arg in "$@"; do
				cmdflags+="$arg "
			done
			cmdflags="${cmdflags::-1}"
			$PI_APPS_DIR/manage uninstall "$cmdflags"
			$PI_APPS_DIR/manage install "$cmdflags" || error "Failed to reinstall \"$cmdflags\"!"
			exit $?
		;;
		list-installed)
			#list all the installed apps
			#list_apps installed
			ls "$PI_APPS_DIR/apps" | GREP_COLORS='ms=1;34' grep --color=always -x "$(grep -rx 'installed' "${PI_APPS_DIR}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!' | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')"
			exit $?
		;;
		list-uninstalled)
			#list all the uninstalled apps
			#list_apps uninstalled
			ls $PI_APPS_DIR | grep --color=always -x "$(grep -rx 'uninstalled' "${PI_APPS_DIR}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!' | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')"
			ls $PI_APPS_DIR | grep --color=always -vx "$(ls "${PI_APPS_DIR}/data/status" | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')"
			exit $?
		;;
		list-corrupted)
			#list all the corrupted apps
			#list_apps corrupted
			ls $PI_APPS_DIR/apps | grep --color=always -x "$(grep -rx 'corrupted' "${PI_APPS_DIR}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!' | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')"
			exit $?
		;;
		list-all)
			#list all the apps
			list-all
			exit $?
		;;
		search)
			shift
			args="$*"
			#search apps
			search "$args"
			exit $?
		;;
		update-apps)
			#update all pi-apps apps
			$PI_APPS_DIR/manage update-all
			exit $?
			;;
		update)
			#update all pi-apps
			echo 'u' | $PI_APPS_DIR/updater
			exit $?
		;;
		website)
			shift
			if [[ "$@" == "" ]]; then
				error "'website' option passed, but no app provided!"
			fi
			args="$*"
			#print the website of a app
			get-website "$args" 2>/dev/null
			if [[ "$website_error" == "1" ]]; then
				echo -e "${red}${bold}ERROR:${normal}${red} There is no app called ${light_red}'$@'${red}!${normal}"
				exit 1
			else
				echo -e "${cyan}${inverted}$@'s website:${normal}"
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
			error "Unknown option '${light_blue}$1${red}'! run ${normal}${white}${dark_grey_background}pi-apps help${normal}${white}${red} to see all options."
		;;
	esac
    shift
done
$PI_APPS_DIR/gui
exit $?
