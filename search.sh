#!/bin/bash

#directory variables
PI_APPS_DIR="$HOME/pi-apps"

function search() {
    for dir in $PI_APPS_DIR/apps/*/; do
        dirname=$(basename "$dir")
        if [[ "$dirname" != "template" ]]; then
            #echo $dirname
		    if [[ $dirname == *$1* ]]; then
				#echo "FIRST"
				echo $dirname
				cat $PI_APPS_DIR/apps/$dirname/description
	    	elif grep -q "$1" "$PI_APPS_DIR/apps/$dirname/description" ; then
				#echo "SECOND"
				echo $dirname
				cat "$PI_APPS_DIR/apps/$dirname/description"
   	    	fi
        fi
    done

}

search "$2"

