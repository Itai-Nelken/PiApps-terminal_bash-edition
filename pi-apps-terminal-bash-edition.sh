#!/bin/bash

### ignore some shellcheck warnings
# shellcheck disable=SC2145,SC2199,SC2068

#directory variables
if [ -z "$DIRECTORY" ]; then
	DIRECTORY="$HOME/pi-apps"
fi

#check if '~/pi-apps/api' exists
if [ ! -f "$DIRECTORY/api" ]; then
	echo -e "\e[1;31m[!] \e[0;31mThe pi-apps \"api\" script doesn't exist!\e[0m"
	exit 1
fi

#run the pi-apps api script to get its functions
source "$DIRECTORY/api" &>/dev/null
#unset the error function from the api script, we wan't to use our own defined later
unset error

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
  echo -e "${red}${bold}[!]${normal} ${light_red}$1${normal}" 1>&2
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
	echo -e "${white}${dark_grey_background}multi-uninstall [app1] [app2]${normal}${white} - uninstall multiple apps at the same time. you can also use ${dark_grey_background}multi-remove${normal}${white}.\n"
	echo -e "${white}${dark_grey_background}reinstall [appname]${normal}${white} - reinstall any app available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}list-all${white}${normal}${white} - print all apps available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}list-installed${normal}${white} - print all installed apps.\n"
	echo -e "${white}${dark_grey_background}list-uninstalled${normal}${white} - print all uninstalled apps.\n"
	echo -e "${white}${dark_grey_background}list-corrupted${normal}${white} - print all apps with the corrupted statu (meaning they failed to install/uninstall).\n"
	echo -e "${white}${dark_grey_background}status [app]${normal}${white} - print the status of a app in pi-apps.\n"
	echo -e "${white}${dark_grey_background}search '[appname]'${normal}${white} - search all apps available in pi-apps (case sensitive).\n"
	echo -e "${white}${dark_grey_background}update${normal}${white} - update all pi-apps components.\n"
	echo -e "${white}${dark_grey_background}update-apps${normal}${white} - update all pi-apps apps only.\n"
	echo -e "${white}${dark_grey_background}website '[appname]'${normal}${white} - print the website of any app in pi-apps.\n"
	echo -e "${white}${dark_grey_background}gui${normal}${white} - launch the pi-apps normally.\n"
	echo -e "${white}${dark_grey_background}help${normal}${white} - show this help.${normal}"
	echo '===================='

	echo -e "\n${cyan}${bold}if you don't supply any option pi-apps will start normally.${normal}"
}

function search() { #search apps using pi-apps's api 'app_search' function
		while read -r line; do
			[[ -z "$line" ]] && continue
			echo -e "${bold}${inverted}${light_blue}$line${normal}"
    	echo -e "${green}$(cat $DIRECTORY/apps/"$line"/description || echo "No description available")${normal}"
		done < <(app_search $1)
}

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
				cmdflags+="$arg\n"
			done
			#remove last \'n'
			args=${cmdflags%\\n}
			#install apps
			"$DIRECTORY/manage" multi-install "$(echo -e "$args")"
			exit $?
		;;
		remove|uninstall)
			shift
			for arg in "$@"; do
				cmdflags+="$arg\n"
			done
			args=${cmdflags%\\n}
			#uninstall apps
			"$DIRECTORY/manage" multi-uninstall "$(echo -e "$args")"
			exit $?
		;;
		reinstall)
			shift
			for arg in "$@"; do
				cmdflags+="$arg "
			done
			cmdflags="${cmdflags::-1}"
			"$DIRECTORY/manage" multi-uninstall "$cmdflags"
			"$DIRECTORY/manage" multi-install "$cmdflags" || error "Failed to reinstall \"$cmdflags\"!"
			exit $?
		;;
		list-installed)
			#list all the installed apps
			#list_apps installed
			list_apps installed
			exit $?
		;;
		list-uninstalled)
			#list all the uninstalled apps
			#list_apps uninstalled
			list_apps uninstalled
			exit $?
		;;
		list-corrupted)
			#list all the corrupted apps
			#list_apps corrupted
			list_apps corrupted
			exit $?
		;;
		list-all)
			#list all the apps
			list_apps all
			exit $?
		;;
		search)
			shift
			app_search $* 2>/dev/null
			exit $?
		;;
		update)
			#update pi-apps
			"$DIRECTORY/updater" cli
			exit $?
		;;
		info)
			shift
			
			if [ -z "$*" ]; then
				error "No app provided."
			else
				app_name="$*"
			fi
				
			if ! [ -d "$DIRECTORY/apps/$app_name" ]; then
				error "App not found."
			fi
			
			description="$(cat "${DIRECTORY}/apps/$app_name/description" || echo 'Description unavailable')$installedpackages"

			abovetext="
- Current status: $(echo "$(app_status "$app_name")" | sed 's/corrupted/corrupted (installation failed)/g' | sed 's/disabled/disabled (installation is prevented on your system)/g')"
			
			if [ -f "${DIRECTORY}/apps/$app_name/website" ];then
				#show website if it exists
				abovetext="$abovetext
- Website: $(cat "${DIRECTORY}/apps/$app_name/website" | head -n1)"

			fi

			if [ -z "$clicklist" ];then
				clicklist="$(usercount)"
			fi

			usercount="$(echo "$clicklist" | grep " $app_name"'$' | awk '{print $1}' | head -n1)"
			if [ ! -z "$usercount" ] && [ "$usercount" -gt 20 ];then
				abovetext="$abovetext
- $(printf "%'d" "$usercount") users"

				if [ "$usercount" -ge 1500 ] && [ "$usercount" -lt 10000 ];then
				  #if a lot of users, add an exclamation point!
				  abovetext="${abovetext}!"
				elif [ "$usercount" -ge 10000 ];then
				  #if a crazy number of users, add two exclamation points!
				  abovetext="${abovetext}!!"
				fi
			fi
			
			status_green "\n\e[4m$app_name"
			status "$abovetext\n"
			echo -e "$description\n" 
		;;
		import)
			shift
			"$DIRECTORY/etc/import-app" $*
			exit $?
		;;
		status)
			shift
			[[ "$@" == "" ]] && error "'status' option passed, but no app provided!"
			status="$(app_status $@)"
			[[ -z "$status" ]] && exit 1;

			# installed=green, uninstalled=yellow, corrupted=red
			case $status in
				installed) color="\e[1;32m" ;;
				uninstalled) color="\e[1;33m" ;;
				corrupted) color="\e[1;31m" ;;
				*) color="\e[1m" ;;
			esac

			echo -e "${bold}${inverted}$@${normal} - ${color}$status${normal}"
			exit 0;
		;;
		gui)
			#open pi-apps regularly
			$DIRECTORY/gui
			exit $?
		;;
		create-app)
			"$DIRECTORY/createapp"
			exit $?
		;;
		settings)
			"$DIRECTORY/settings"
			exit $?
		;;
		-v | --version | version | about | --about)
			#display about
			about
			exit 0
		;;
		*)
			error "Unknown option '${light_blue}$1${light_red}'! run ${normal}${white}${dark_grey_background}pi-apps help${normal}${white}${light_red} to see all options."
		;;
	esac
    shift
done
exit $?
