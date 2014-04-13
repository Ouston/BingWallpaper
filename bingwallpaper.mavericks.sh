#! /bin/bash
# name: bingwallpaper
# date: March 11 2014
# author: Ouston
# mail: ouston@me.com
# 
# This script was made for OS X 10.9 Mavericks.
# Inspired by Whizzzkid's script (me@nishantarora.in) http://code.nishantarora.in/bing-wallpapers-for-linux
#
# To run the script on startup
# Open the Terminal app
# Edit the crontab:	> crontab -e
# Add the line:	@reboot /path/to/the/script
# Make sure the script has executable attribute: > sudo chmod +x /path/to/the/script).
# Enjoy new beautiful wallpapers every day :)

#######################################################################
############################## PARAMETERS #############################
#######################################################################

# Collection Path (set the folder of archived wallpapers)
desktopPath="$HOME/Pictures/Bing Wallpapers/"
# Size of the picture corresponding to your screen definition
size="1920x1200"
# The day you want the picture, 0=today, 1=yesterday... 
day="0"

#######################################################################
##################### DO NOT EDIT BELOW THIS LINE #####################
#######################################################################

bing="http://www.bing.com"						# Bing domain
api="/HPImageArchive.aspx?"						# API end point
format="js"										# Response format (js|xml)
market="en-US"									# Market place
const="1"										# API Constant (fetch how many)
reqImg=$bing$api"&format="$format"&idx="$day"&mkt="$market"&n="$const	# Required Image Uri

# COMPLETE URL: http://www.bing.com/HPImageArchive.aspx?&format=js&idx=0&mkt=en-US&n=1

apiResp=$(curl -s $reqImg)						# Fetching API response

# Default image definition URL in case the required is not available
# Search for pattern < url":"blabla > and keep the third field (blabla=[^\"]*=some_characters_except_the_"_character) with " separator
defImgURL=$bing$(echo $apiResp | grep -Eo "url\":\"[^\"]*" | cut -d "\"" -f 3)

# Req image url (raw)
reqImgURL=$bing$(echo $apiResp | grep -Eo "urlbase\":\"[^\"]*" | cut -d "\"" -f 3)"_"$size".jpg"

# Getting Image Name
reqImgName=${reqImgURL##*/}
defImgName=${defImgURL##*/}

clear; echo
if [ -f "$desktopPath$reqImgName" ]; then
	downloadedStatus=true
	imgName=$reqImgName
	echo "Wallpaper already downloaded"
else
	echo "Downloading..."
	if $(curl -# -f -o "$desktopPath$reqImgName" --create-dirs $reqImgURL); then
		downloadedStatus=true
		imgName=$reqImgName
		echo "Wallpaper \"$imgName\" downloaded"
	else
		echo -e "Definition not available\n"
		echo "Searching for another definition..."
		if [ -f "$desktopPath$defImgName" ]; then
			imgName=$defImgName
			downloadedStatus=true
			echo "Default definition already downloaded"
		else
			if $(curl -# -f -o "$desktopPath$defImgName" --create-dirs $defImgURL); then
				downloadedStatus=true
				imgName=$defImgName
				echo "Wallpaper \"$imgName\" downloaded"
			else
			 	downloadedStatus=false
				echo "Error downloading wallpaper :("
				echo "Aborting process..."
			fi
		fi
	fi
fi
if $downloadedStatus; then

	currentDB="$HOME/Library/Application Support/Dock/desktoppicture.db"

	######################## SET THE SYSTEM DEFAULT PICTURE BACKBROUND #########################
	# currentLink="/System/library/CoreServices/DefaultDesktop.jpg"
	# if [ -f "$currentDB" ]; then
	# 	echo -en "\nClearing cache..."
	# 	rm "$currentDB" && echo "Cache cleared" || echo "Impossible to clear cache files"
	# fi
	# if [[ $(readlink "$currentLink") != "$systemPath$imgName" ]]; then
	# 	rm "/System/Library/CoreServices/DefaultDesktop.jpg"
	# 	ln -s "$systemPath$imgName" "/System/Library/CoreServices/DefaultDesktop.jpg"
	# 	echo "Modification applied"
	# else
	# 	echo "System background was already set"
	# fi
	############################################################################################

	# SET THE WALLPAPER OF OS X MAVERICKS
	sqlite3 "$currentDB" "UPDATE data SET value = '$desktopPath$imgName';"

	# SET WALLPAPER FOR OS X BEFORE 10.9 MAVERICKS
	# osascript -e 'tell application "System Events" to set picture of every desktop to "$desktopPath$imgName"'

	if [[ $#==0 ]]; then
		echo "Wallpaper succefully set :)"
		killall Dock
	fi
fi
SECS=5
echo -e '\nPress Ctrl-C to STOP the countdown'
while [[ 0 -ne $SECS ]]; do
		echo -n "$SECS"
		sleep .33
		echo -n '.'
		sleep .33
		echo -n '.'
		sleep .33
		SECS=$[$SECS-1]
done
echo -e 'Bye bye\n'
sleep 1
osascript -e 'tell application "Terminal" to quit' &
