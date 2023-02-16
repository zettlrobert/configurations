#!/usr/bin/env bash

# Colors to use in the script
export red='\x1b[0;31m'
export green='\x1b[0;32m'
export yellow='\x1b[0;33m'
export lightblue='\x1b[1;34m'
export purple='\x1b[0;35m'
export cyan='\x1b[0;36m'
export lightgreen='\x1b[1;32m'
export lightgray='\x1b[1;37m'
export NC='\x1b[0m'

DIR="${BASH_SOURCE%/*}"

function verify_command {
	message=$1
	exitCode=$2

	if [[ $exitCode == "0" ]]; then
		echo -e "[${green}OK${NC}]\t\t $message"
	else
		echo -e "[${red}FAIL${NC}]\t\t $message"
	fi
}

# Welcome Message
echo -e "Welcome to the simple installation, script enter password when prompted. \nThis script assumes you have cloned this repository"

# Update System Dependencies and Upgrade
sudo apt update && sudo apt upgrade -y

# #########################################################################################################################
# Setup home directory structure
# #########################################################################################################################
DIRECTORIES=(
	'audiobooks'
	'bin'
	'containers'
	'desktop'
	'development'
	'documents'
	'downloads'
	'misc'
	'music'
	'pictures'
	'projects'
	'public'
	'scripts'
	'templates'
	'test'
	'videos'
	'vms'
)

function remove_base_directories {
	# Move to user home directory
	cd "$HOME" || exit

	# Delete all directgories
	rm -r "$HOME"/Documents "$HOME"/Music "$HOME"/Public "$HOME"/Videos "$HOME"/Desktop "$HOME"/Downloads "$HOME"/Pictures "$HOME"/Templates

	# Clone this repository
	git clone https://github.com/zettlrobert/configurations.git
}

function create_new_directories {
	# Create new directory for every string in array
	for directory in "${DIRECTORIES[@]}"; do
		mkdir "$directory"
		exitCode=$?

		verify_command "creating $directory" $exitCode
	done
}

function update_xdg_user_dirs {
	# Remvoe default xdg directory configuration
	rm "$HOME"/.config/user-dirs.dirs
	exitCodeRmUserDirs=$?
	verify_command "removing user-dirs.dirs" $exitCodeRmUserDirs

	# Copy user.user-dirs.dirs from assets
	cp "$HOME"/configurations/pop/assets/user-dirs.dirs "$HOME"/.config
}

remove_base_directories
create_new_directories
update_xdg_user_dirs

echo -e "Tasks\n\
  - Switch Keyboard Shurtcuts, (super for workspace overview)\n\
  - Update github ssh keys with: .ssh/id_rsa.pub
  - Adjust download folder in tools(browser) to downloads instead of Downloads
"

# TODO:
# update function
