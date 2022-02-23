#!/bin/bash

### ignore some shellcheck warnings ###
# shellcheck disable=2034,2154,1091

#directory variables
if [[ -z "$DIRECTORY" ]]; then
	DIRECTORY="$HOME/pi-apps"
fi

#check if "$DIRECTORY/api" exists
if [[ ! -f "$DIRECTORY/api" ]]; then
	echo -e "\e[1;31m[!] \e[0;31mThe pi-apps \"api\" script doesn't exist!\e[0m"
	echo -e "Please report this here: https://github.com/Itai-Nelken/PiApps-terminal_bash-edition/issues/new"	
	exit 1
fi

#run the pi-apps api script to get its functions
if ! source "$DIRECTORY/api" &>/dev/null; then
	echo -e "${red}${bold}[!]${normal} ${light_red}Failed to source pi-apps api.${normal}" 1>&2
	exit 1
fi
#unset the error function from the api script, we wan't to use our own defined later
unset error

#text formatting variables
readonly red="\e[31m"
readonly green="\e[32m"
readonly yellow="\e[33m"
readonly blue="\e[34m"
readonly light_red="\e[91m"
readonly light_green="\e[92m"
readonly light_yellow="\e[93m"
readonly light_blue="\e[94m"
readonly cyan="\e[36m"
readonly white="\e[97m"
readonly dark_grey_background="\e[100m"
readonly bold="\e[1m"
readonly underline="\e[4m"
readonly inverted="\e[7m"
readonly normal="\e[0m"

function error() {
  echo -e "${red}${bold}[!]${normal} ${light_red}$1${normal}" 1>&2
  exit 1
}

function about() {
    echo -e '
    ####################################
    # Pi-Apps terminal - bash edition  #
    # -------------------------------- #
    #    By Itai-Nelken | 2021-2022    #
    # ================================ #
    #        Pi-Apps by Botspot        #
    ####################################
    '
}

function list_apps() { # $1 can be: installed, uninstalled, corrupted, cpu_installable, hidden, visible, online, online_only, local, local_only
  if [[ -z "$1" ]] || [[ "$1" == local ]];then
    #list all apps
    grep -v template <(ls "${DIRECTORY}/apps")
    
  elif [[ "$1" == all ]];then
    #combined list of apps, both online and local. Removes duplicate apps from the list.
    echo -e "$(list_apps local)\n$(list_apps online)" | sort | uniq
    
  elif [[ "$1" == "installed" ]];then
    #list apps      |   only show      (          list of installed apps                | remove match string  |   basename   )
    list_apps local | list_intersect "$(grep -rx 'installed' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!')"
    
  elif [[ "$1" == "corrupted" ]];then
    #list apps      |only show         (          list of corrupted apps                | remove match string  |   basename   )
    list_apps local | list_intersect "$(grep -rx 'corrupted' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!')"
    
  elif [[ "$1" == "disabled" ]];then
    #list apps      |    only show     (          list of disabled apps                | remove match string  |   basename   )
    list_apps local | list_intersect "$(grep -rx 'disabled' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!')"
    
  elif [[ "$1" == "uninstalled" ]];then
    #list apps that have a status file matching "uninstalled"
    list_apps local | list_intersect "$(grep -rx 'uninstalled' "${DIRECTORY}/data/status" | awk -F: '{print $1}' | sed 's!.*/!!')"
    #also list apps that don't have a status file
    list_apps local | list_subtract "$(ls "${DIRECTORY}/data/status")"
    
  elif [[ "$1" == "have_status" ]];then
    #list apps that have a status file
    list_apps local | list_intersect "$(ls "${DIRECTORY}/data/status")"
    
  elif [[ "$1" == "missing_status" ]];then
    #list apps that don't have a status file
    list_apps local | list_subtract "$(ls "${DIRECTORY}/data/status")"
    
  elif [[ "$1" == "cpu_installable" ]];then
    #list apps that can be installed on the device's OS architecture (32-bit or 64-bit)
    #find all apps that have install-XX script, install script, or a packages file
    find "${DIRECTORY}/apps" -type f \( -name "install-$arch" -o -name "install" -o -name "packages" \) | sed "s+${DIRECTORY}/apps/++g" | sed 's+/.*++g' | sort | uniq | grep -v template 
    
  elif [[ "$1" == "package" ]];then
    #list apps that have a "packages" file
    find "${DIRECTORY}/apps" -type f -name "packages" | sed "s+/packages++g" | sed "s+${DIRECTORY}/apps/++g" | sort | uniq | grep -v template 
    
  elif [[ "$1" == "standard" ]];then
    #list apps that have scripts
    find "${DIRECTORY}/apps" -type f \( -name "install-32" -o -name "install-64" -o -name "install" -o -name "uninstall" \) | sed "s+${DIRECTORY}/apps/++g" | sed 's+/.*++g' | sort | uniq | grep -v template 
    
  elif [[ "$1" == "hidden" ]];then
    #list apps that are hidden
    read_category_files | grep '|hidden' | awk -F'|' '{print $1}'
    
  elif [[ "$1" == "visible" ]];then
    #list apps that are in any other category but 'hidden', and aren't disabled
    read_category_files | grep -v '|hidden' | awk -F'|' '{print $1}' # | list_subtract "$(list_apps disabled)"
    
  elif [[ "$1" == "online" ]];then
    #list apps that exist on the online git repo
    if [[ -d "${DIRECTORY}/update/pi-apps/apps" ]];then
      #if update folder exists, just use that
      ls "${DIRECTORY}/update/pi-apps/apps" -I template 
    else
      #if update folder doesn't exist, then parse github HTML to get a list of online apps. Horrible idea, but it works!
      wget -qO- "https://github.com/Botspot/pi-apps/tree/master/apps" | grep 'title=".*" data-pjax=' -o | sed 's/title="//g' | sed 's/" data-pjax=//g' | grep -v template 
    fi
    
  elif [[ "$1" == "online_only" ]];then
    #list apps that exist only on the git repo, and not locally
    list_apps online | list_subtract "$(list_apps local)"
    
  elif [[ "$1" == "local_only" ]];then
    #list apps that exist only locally, and not on the git repo
    list_apps local | list_subtract "$(list_apps online)"
    
  else
    error "list_apps(): unrecognized filter '$1'!"
  fi
}

function help() {
	echo -e "\n${white}${inverted}${bold}${light_blue}USAGE:${normal}"
	echo '-------'
	#echo -e "${underline}${light_green}./pi-apps-terminal-bash-edition.sh [option]${normal}"
	echo -e "${white}${underline}${light_green}pi-apps [option] [arguments]${normal}"
	echo -e "\n${white}${inverted}${bold}${light_blue}Available options:${normal}"
	echo '-------------------'
	echo -e "${white}${dark_grey_background}install [app]${normal}${white} - install any app available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}uninstall/remove [app]${normal}${white} - uninstall any app available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}reinstall [app]${normal}${white} - reinstall any app available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}list-all [-d|--description]${white}${normal}${white} - print all apps available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}list-installed [-d|--description]${normal}${white} - print all installed apps.\n"
	echo -e "${white}${dark_grey_background}list-uninstalled [-d|--description]${normal}${white} - print all uninstalled apps.\n"
	echo -e "${white}${dark_grey_background}list-corrupted [-d|--description]${normal}${white} - print all apps failed to install/uninstall (are corrupted).\n"
	echo -e "${white}${dark_grey_background}status [app]${normal}${white} - print the status of a app in pi-apps.\n"
	echo -e "${white}${dark_grey_background}search [query]${normal}${white} - search all apps available in pi-apps.\n"
	echo -e "${white}${dark_grey_background}website [app]${normal}${white} - print the link to the website of any app in pi-apps.\n"
	echo -e "${white}${dark_grey_background}update [--yes|-y]${normal}${white} - update all apps and pi-apps itself.\n"
	echo -e "${white}${dark_grey_background}info/details [app]${normal}${white} - print the information of any app in pi-apps.\n"
	echo -e "${white}${dark_grey_background}gui${normal}${white} - launch pi-apps normally.\n"
	echo -e "${white}${dark_grey_background}help${normal}${white} - show this help.${normal}"
	echo '===================='

	echo -e "\n${cyan}${bold}If you don't supply any option, pi-apps will start normally.${normal}"
}

# $*: space separated list of apps to install
function multi_install() {
	for arg in "$@"; do
		cmdflags+="$arg\n"
	done
	# remove last newline ('\n')
	args=${cmdflags%\\n}
	# install apps
	"$DIRECTORY/manage" multi-install "$(echo -e "$args")"
	# clean up
	unset arg cmdflags argsSS
	return $?
}

# $*: query
# prints to stdout the list of matches separated by newlines
function fuzzy_search() {
	# disable 'dont use ls | grep' only for this function
	# shellcheck disable=2010
	list_apps cpu_installable | grep -i "$*"
}

while [[ "$1" != "" ]]; do
	case $1 in
		-h | --help | -help | help)
			# show the help
			help
			exit 0
		;;
		# TODO: add multi-install back somehow
		install)
			shift
			# if only one app is provided (it has a folder with its name)
			if [[ -d "$DIRECTORY/apps/$*" ]]; then
				"$DIRECTORY/manage" install "$*"
				exit $?
			else
				# case insensitive search
				app="${*,,}"
				match=false
				
				# search for matches.
				# if match is found, put the correct app name in '$folder' and break from the loop
				old_ifs=$IFS
				IFS=$'\n'
				for folder in "$DIRECTORY"/apps/*; do
					if [[ "$app" == "$(basename "${folder,,}")" ]]; then
						app="$folder"
						match=true
						break
					fi
				done
				IFS=$old_ifs
				unset old_ifs
				
				# if a match was found, install it and exit.
				if $match; then
					"$DIRECTORY/manage" install "$app"
					exit $?
				else # else perform a fuzzy search
					unset match

					# fill 'matches' with all search results
					matches=()
					old_ifs=$IFS
					IFS=$'\n'
					for m in $(fuzzy_search "$@"); do
						if [[ -z "$m" ]]; then
							continue
						fi
						matches+=("$m")
					done
					IFS=$old_ifs
					unset m old_ifs
					# if no matches found, error and exit
					if [[ ${#matches[@]} -eq 0 ]]; then
						error "No matches found for app(s) '$*'!"
					fi

					# ask user if any of the matches are correct
					echo "No apps found for your input ('$*')."
					echo "But found the following apps:"
					idx=0
					for m in "${matches[@]}"; do
						echo -e " $((idx +1 )). '$m'"
						idx=$((idx+1))
					done
					while true; do
						read -rp "Enter the index of the correct app or 'q' to exit: " answer
						if [[ "$answer" =~ [qQ] ]]; then
							echo "Exiting"
							exit 0
						fi
						if ! [[ "$answer" =~ ^[0-9]+$ ]]; then
							echo "Input isn't a number! try again."
							continue
						fi
						if [[ $answer -gt $idx ]]; then
							echo "Input is larger than the available number of options! try again."
							continue
						elif [[ $answer -lt 1 ]]; then
							echo "Input is smaller than 1! try again."
							continue
						fi
						break
					done
					# past here, $answer is a number between 1 and the amount of options.
					app="${matches[$((answer - 1))]}" # -1 because array indexes start at 0, but input starts at 1.
					"$DIRECTORY/manage" install "$app"
					exit $?
				fi
			fi
		;;
		remove|uninstall)
			shift
			if [[ -d "$DIRECTORY/apps/$*" ]]; then # if only one app provided
				"$DIRECTORY/manage" uninstall "$*"
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
			if [[ -d "$DIRECTORY/apps/$*" ]]; then # if only one app provided
				"$DIRECTORY/manage" uninstall "$*"
				"$DIRECTORY/manage" install "$*"
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
			arg="$*"
			IFS=$'\n'
			while read -r line; do
				[[ -z "$line" ]] && continue
				echo -e "\n\n${underline}$line${normal}\n" | grep -E -i "${arg}|" --color=always
				echo -e "$(cat "$DIRECTORY/apps/$line/description" || echo "No description available")${normal}\n" | grep -E -i "${arg}|" --color=always
			done < <(for app in $(grep -ilrw "$DIRECTORY/apps" -e "$@" --include description | awk '!seen[$0]++'; find "$DIRECTORY/apps" -maxdepth 1 -type d -name "$@" -printf '%f\n'); do grep -q "^/" <<< "$app" && basename "$(dirname "$app")" || echo "$app"; done | awk '!seen[$0]++')
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
		info|details)
			shift
			
			if [[ -z "$*" ]]; then
				error "No app provided."
			else
				app_name="$*"
			fi
				
			if ! [[ -d "$DIRECTORY/apps/$app_name" ]]; then
				error "App not found."
			fi
			
			description="$(cat "${DIRECTORY}/apps/$app_name/description" || echo 'Description unavailable')"

			abovetext="
- Current status: $(app_status "$app_name" | sed 's/corrupted/corrupted (installation failed)/g' | sed 's/disabled/disabled (installation is prevented on your system)/g')"
			
			if [[ -f "${DIRECTORY}/apps/$app_name/website" ]];then
				#show website if it exists
				abovetext="$abovetext
- Website: $(head -n1 < "${DIRECTORY}/apps/$app_name/website")"

			fi

			if [[ -z "$clicklist" ]];then
				clicklist="$(usercount)"
			fi

			usercount="$(echo "$clicklist" | grep " $app_name"'$' | awk '{print $1}' | head -n1)"
			if [[ -n "$usercount" ]] && [[ "$usercount" -gt 20 ]];then
				abovetext="$abovetext
- $(printf %d "$usercount") users"

				if [[ "$usercount" -ge 1500 ]] && [[ "$usercount" -lt 10000 ]];then
				  #if a lot of users, add an exclamation point!
				  abovetext="${abovetext}!"
				elif [[ "$usercount" -ge 10000 ]];then
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
			if [[ -z "$*" ]]; then
				error "No app provided."
			fi
			if [[ ! -d "$DIRECTORY/apps/$*" ]]; then
				error "App '${app}' doesn't exist!"
			fi
	
			website="$(cat "$DIRECTORY/apps/${app}/website" 2>/dev/null)" || error "Failed to read '${DIRECTORY}/apps/${app}/website'!"
			echo -e "${bold}${inverted}$*${normal} - ${green}$website${normal}" 2>/dev/null 
			exit 0
		;;
		status)
			shift
			[[ "$*" == "" ]] && error "'status' option passed, but no app provided!"
			status="$(app_status "$*")"
			[[ -z "$status" ]] && exit 1;

			# installed=green, uninstalled=yellow, corrupted=red
			case $status in
				installed) color="\e[1;32m" ;;
				uninstalled) color="\e[1;33m" ;;
				corrupted) color="\e[1;31m" ;;
				*) color="\e[1m" ;;
			esac

			echo -e "${bold}${inverted}$*${normal} - ${color}$status${normal}"
			exit 0;
		;;
		gui)
			# run pi-apps regularly
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
