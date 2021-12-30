#!/bin/bash

### ignore some shellcheck warnings
# shellcheck disable=SC2145,SC2199,SC2068,SC2013,SC1090,SC2034

#directory variables
if [ -z "$DIRECTORY" ]; then
	DIRECTORY="$HOME/pi-apps"
fi

#check if "$DIRECTORY/api" exists
if [[ ! -f "$DIRECTORY/api" ]]; then
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
	echo -e "${white}${underline}${light_green}pi-apps [option] [args]${normal}"
	echo -e "\n${white}${inverted}${bold}${light_blue}Available options:${normal}"
	echo '-------------------'
	echo -e "${white}${dark_grey_background}install [appname]${normal}${white} - install any apps available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}uninstall/remove [appname]${normal}${white} - uninstall any apps available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}reinstall [appname]${normal}${white} - reinstall any apps available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}list-all [-d|--description]${white}${normal}${white} - print all apps available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}list-installed [-d|--description]${normal}${white} - print all installed apps.\n"
	echo -e "${white}${dark_grey_background}list-uninstalled [-d|--description]${normal}${white} - print all uninstalled apps.\n"
	echo -e "${white}${dark_grey_background}list-corrupted [-d|--description]${normal}${white} - print all apps failed to install/uninstall (are corrupted).\n"
	echo -e "${white}${dark_grey_background}status [app]${normal}${white} - print the status of a app in pi-apps.\n"
	echo -e "${white}${dark_grey_background}search [args]${normal}${white} - search all apps available in pi-apps (case sensitive).\n"
	echo -e "${white}${dark_grey_background}website [app]${normal}${white} - print the website of an app in pi-apps.\n"
	echo -e "${white}${dark_grey_background}update [--yes|-y]${normal}${white} - update pi-apps in GUI or CLI.\n"
	echo -e "${white}${dark_grey_background}info [appname]${normal}${white} - print the information of any app in pi-apps.\n"
	echo -e "${white}${dark_grey_background}gui${normal}${white} - launch the pi-apps normally.\n"
	echo -e "${white}${dark_grey_background}help${normal}${white} - show this help.${normal}"
	echo '===================='

	echo -e "\n${cyan}${bold}If you don't supply any option, pi-apps will start normally.${normal}"
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
			if [ -d "$DIRECTORY/apps/$*" ]; then # if only one app is provided
				for arg in "$@"; do
					cmdflags+="$arg "
				done
				"$DIRECTORY/manage" install "$cmdflags"
				exit $?
			else # multiple apps
				for arg in "$@"; do
					cmdflags+="$arg\n"
				done
				# remove last newline ('\n')
				args=${cmdflags%\\n}
				#install apps
				"$DIRECTORY/manage" multi-install "$(echo -e "$args")"
				exit $?
			fi
		;;
		remove|uninstall)
			shift
			if [ -d "$DIRECTORY/apps/$*" ]; then # if only one app provided
				for arg in "$@"; do
					cmdflags+="$arg "
				done
				"$DIRECTORY/manage" uninstall "$cmdflags"
				exit $?
			else #multiple app
				for arg in "$@"; do
					cmdflags+="$arg\n"
				done
				# remove last newline ('\n')
				args=${cmdflags%\\n}
				#uninstall apps
				"$DIRECTORY/manage" multi-uninstall "$(echo -e "$args")"
				exit $?
			fi
		;;
		reinstall)
			shift
			if [ -d "$DIRECTORY/apps/$*" ]; then # if only one app provided
				for arg in "$@"; do
					cmdflags+="$arg "
				done
				"$DIRECTORY/manage" uninstall "$cmdflags"
				"$DIRECTORY/manage" install "$cmdflags"
				exit $?
			else # multiple apps
				for arg in "$@"; do
					cmdflags+="$arg\n"
				done
				#remove last \'n'
				args=${cmdflags%\\n}
				"$DIRECTORY/manage" multi-uninstall "$(echo -e "$args")"
				"$DIRECTORY/manage" multi-install "$(echo -e "$args")"
				exit $?
			fi
		;;
		list-installed)
			shift
			#list all the installed apps
			#list_apps installed
			case $1 in
				-d|--description) #print with descriptions
					IFS=$'\n'
					for app in $(list_apps cpu_installable | grep -x "$(grep -rx 'installed' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!')" | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g'); do
						echo -e "\n${bold}${inverted}${light_blue}$app${normal}"
						echo -e "${green}$(cat "$DIRECTORY/apps/$app/description")${normal}"
					done
				;;
				*)
					IFS=$'\n'
					for app in $(list_apps cpu_installable | grep -x "$(grep -rx 'installed' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!')" | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g'); do
						echo -e "\n${bold}${inverted}${light_blue}$app${normal}"
					done
				;;
			esac
			echo
			exit $?
		;;
		list-uninstalled)
			shift
			#list all the uninstalled apps
			#list_apps uninstalled
			case $1 in
				-d|--description) #print with descriptions
					IFS=$'\n'
					for app in $(sort <(grep -rx 'uninstalled' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!'; list_apps cpu_installable | grep -vx "$(find "${DIRECTORY}/data/status" -type f -printf "%f\n" | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')")); do
						echo -e "\n${bold}${inverted}${light_blue}$app${normal}"
						echo -e "${green}$(cat "$DIRECTORY/apps/$app/description")${normal}"
					done
				;;
				*)
					IFS=$'\n'
					for app in $(sort <(grep -rx 'uninstalled' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!'; list_apps cpu_installable | grep -vx "$(find "${DIRECTORY}/data/status" -type f -printf "%f\n" | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g')")); do
						echo -e "\n${bold}${inverted}${light_blue}$app${normal}"
					done
				;;
			esac
			echo  
			exit $?
		;;
		list-corrupted)
			shift
			#list all the corrupted apps
			#list_apps corrupted
			case $1 in
				-d|--description) #print with descriptions
					IFS=$'\n'
					for app in $(list_apps cpu_installable | grep -x "$(grep -rx 'corrupted' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!')" | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g'); do
						echo -e "\n${bold}${inverted}${light_blue}$app${normal}"
						echo -e "${green}$(cat "$DIRECTORY/apps/$app/description")${normal}"
					done
				;;
				*)
					IFS=$'\n'
					for app in $(list_apps cpu_installable | grep -x "$(grep -rx 'corrupted' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!')" | sed -z 's/\n/\\|/g' | sed -z 's/\\|$/\n/g'); do
						echo -e "\n${bold}${inverted}${light_blue}$app${normal}"
					done
				;;
			esac
			echo
			exit $?
		;;
		list-all)
			shift
			case $1 in
				-d|--description) #print with descriptions
					#list all the apps
					IFS=$'\n'
					for app in $(list_apps cpu_installable); do
					     echo -e "\n${bold}${inverted}${light_blue}$app${normal}"
					     echo -e "${green}$(cat "$DIRECTORY/apps/$app/description")${normal}"
					done	
				;;
				*)
					IFS=$'\n'
					for app in $(list_apps cpu_installable); do
					     echo -e "\n${bold}${inverted}${light_blue}$app${normal}"
					done	
				;;
			esac
			exit $?
		;;
		search)
			shift
			while read -r line; do
				[[ -z "$line" ]] && continue
				echo -e "${bold}${inverted}${light_blue}${underline}$line${normal}\n"
				echo -e "${green}$(cat "$DIRECTORY/apps/$line/description" || echo "No description available")${normal}\n"
			done < <(app_search "$1" 2>/dev/null)
			exit $?
		;;
		update)
			#update pi-apps
			shift
			case $1 in
				--yes|-y)
					"$DIRECTORY/updater" cli-yes
				;;
				*)
					"$DIRECTORY/updater" cli
				;;
			esac
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
			
			description="$(cat "${DIRECTORY}/apps/$app_name/description" || echo 'Description unavailable')"

			abovetext="
- Current status: $(app_status "$app_name" | sed 's/corrupted/corrupted (installation failed)/g' | sed 's/disabled/disabled (installation is prevented on your system)/g')"
			
			if [ -f "${DIRECTORY}/apps/$app_name/website" ];then
				#show website if it exists
				abovetext="$abovetext
- Website: $(head -n1 < "${DIRECTORY}/apps/$app_name/website")"

			fi

			if [ -z "$clicklist" ];then
				clicklist="$(usercount)"
			fi

			usercount="$(echo "$clicklist" | grep " $app_name"'$' | awk '{print $1}' | head -n1)"
			if [ -n "$usercount" ] && [ "$usercount" -gt 20 ];then
				abovetext="$abovetext
- $(printf %d "$usercount") users"

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
			exit 0
		;;
		website)
			shift
			if [ -z "$*" ]; then
				error "No app provided."
			fi
			website="$(cat "$DIRECTORY/apps/$@/website" 2>/dev/null)" || error "'$@' not found."
			echo -e "${bold}${inverted}$@${normal} - ${green}$website${normal}" 2>/dev/null 
			exit 0
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
			"$DIRECTORY/gui"
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

"$DIRECTORY/gui" # launch pi-apps regularly if no (known) arguments provided
exit $?
