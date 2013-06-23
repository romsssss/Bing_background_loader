#!/bin/bash
# Description :
#       Shell script updating GNOME background with Bing picture of the day.
# Author : Romain Vigo Benia
# Last update: June - 2013
# --------------------------------------------------------------------------------



##################################
###    SCRIPT CONFIGURATION    ###
##################################
# Where the background images will be saved
BACKGROUND_DIRECTORY=$HOME'/Pictures/Bing_backgrounds/'

# Which version of bing to use
# possible values : en-US, zh-CN, ja-JP, en-AU, en-UK, de-DE, en-NZ, en-CA, fr-FR, it-IT, ...
BING_COUNTRY='fr-FR'

# Background resolution
# Possible values : "1024x768" "1280x720" "1366x768" ("1920x1200")
RESOLUTION="1366x768"




##################################
###      SCRIPT FUNCTIONS      ###
##################################
# Curl path
curl="$(which curl)"

# Dependencies checking
check_dependencies(){
	if [ ! -n "$curl" ]
		then
		echo "Error : curl package not found ('sudo apt-get install curl' to install it)"
		exit 1
	fi
}

# Get the url of today's background image from bing archives
get_background_url(){
	# Bing url
	bing_url='http://www.bing.com'
	# Bing background archive manager
	bing_archive_url='http://www.bing.com/HPImageArchive.aspx'

	xml_info_url=$bing_archive_url'?format=xml&idx=0&n=1&mkt='$BING_COUNTRY

	background_name=$(echo $($curl -s $xml_info_url) | grep -oP "<urlBase>(.*)</urlBase>" | cut -d ">" -f 2 | cut -d "<" -f 1)

	url=$bing$background_name"_"$RESOLUTION".jpg"

	echo $bing_url$url
}

# Download and save localy a copy of the background
download_background (){
	file_name=$BACKGROUND_DIRECTORY$(date +"%Y-%m-%d")".jpg"
	$curl -s -o $file_name $1
	echo $file_name
}

set_background(){
	gnome_version=`echo $(gnome-session --version) | cut -d ' ' -f2 | cut -d '.' -f1`

	if [ $gnome_version -gt 2 ]	#Gnome3
		then
		gsettings set org.gnome.desktop.background picture-uri file://$1
	else	#Gnome2
		# Need to load an inexisting image first to force the reload
		gconftool -s -t string /desktop/gnome/background/picture_filename /usr/share/backgrounds/dummy.jpg
		# load new desktop background image
		gconftool -s -t string /desktop/gnome/background/picture_filename $1
	fi
}



##################################
###        SCRIPT CORE         ###
##################################

## 1. Check if the dependencies are present
check_dependencies

## 2. Creation of background directory if it does not already exist
mkdir -p $BACKGROUND_DIRECTORY

## 3. Get the right image url from the archive manager
background_url=$(get_background_url)

## 4. Download the background
image_path=$(download_background $background_url)

## 5. set the background
set_background $image_path
