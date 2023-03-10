#!/usr/bin/env bash

# Colors to use in the script
export red='\x1b[0;31m'
export green='\x1b[0;32m'
export purple='\x1b[0;35m'
export cyan='\x1b[0;36m'
export NC='\x1b[0m'

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
echo -e "Welcome to the simple installation, script enter password when prompted. \nThis script assumes you have cloned this repository\nPlease act when prompted"

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

	# Delete all directories
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
	# Remove default XDG directory configuration
	rm "$HOME"/.config/user-dirs.dirs
	exitCodeRmUserDirs=$?
	verify_command "removing user-dirs.dirs" $exitCodeRmUserDirs

	# Copy user.user-dirs.dirs from assets
	cp "$HOME"/configurations/pop/assets/user-dirs.dirs "$HOME"/.config
}

remove_base_directories
create_new_directories
update_xdg_user_dirs

function install_default_packages {
	PACKAGES=(
		# Tools
		"zsh"
		"kitty"
		"bat"
		"ranger"
		"ripgrep"
		"xclip"
		"exa"
		"timeshift"
		"deja-dup"
		"neofetch"
		"openssh-server"
		"code"
		"cifs-utils"
		"nmap"
		# NTFS
		"fuse"
		"ntfs-3g"
		# Media
		"ffmpeg"
		"webp" # Convert webp to png
		# Archives
		"zip"
		"unzip"
		# Theming
		"gtk2-engines-murrine"
		"gnome-tweaks"
		# Fonts
		"fonts-powerline"
		"fonts-firacode"
		# Nvim prerequisites
		"ninja-build"
		"gettext"
		"libtool"
		"libtool-bin"
		"autoconf"
		"automake"
		"cmake"
		"g++"
		"pkg-config"
	)

	for package in "${PACKAGES[@]}"; do
		sudo apt install "$package" -y
		exitCode=$?
		verify_command "$package installation" $exitCode
	done
}
install_default_packages

function update_git_most_recent {
	sudo add-apt-repository ppa:git-core/ppa -y
	sudo apt update
	sudo apt install git -y
}
update_git_most_recent

function change_shell_zsh {
	chsh -s "$(which zsh)"
	exitCode=$?
	verify_command "changing shell to zsh" $exitCode
}
change_shell_zsh

function install_fzf {
	echo -e "${cyan}The following has three questions answer${NC}${purple}Y${NC}${cyan}to all${NC}"
	cd "$HOME" || exit
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	"$HOME"/.fzf/install
}
install_fzf

function install_zap {
	zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
}
install_zap

function set_default_terminal_emulator_kitty {
	gsettings set org.gnome.desktop.default-applications.terminal exec kitty
	exitCode=$?
	verify_command "kitty set as default" $exitCode
}
set_default_terminal_emulator_kitty

function overwrite_zsh_config {
	rm "$HOME"/.zshrc
	cp "$HOME"/configurations/pop/assets/.zshrc "$HOME"/
	exitCode=$?
	verify_command "updating .zshrc" "$exitCode"
}

function set_git_config {
	echo -e "Please provide your git user name"
	read -r username
	git config --global user.name "$username"
	exitCodeUserName=$?
	verify_command "set git user name" $exitCodeUserName

	echo -e "Please provide your git email"
	read -r email
	git config --global user.email "$email"
	exitCodeUserEmail=$?
	verify_command "set git user email" $exitCodeUserEmail

	git config --global init.defaultBranch main
	exitCodeDefaultBranch=$?
	verify_command "set git default branch to main" $exitCodeDefaultBranch

	git config --global pull.ff only
	exitCodeFFOnly=$?
	verify_command "set pull fast forward only" $exitCodeFFOnly
}
set_git_config

function install_nvm {
	cd "$HOME" || exit
	git clone --depth 1 https://github.com/nvm-sh/nvm.git
	"$HOME"/nvm/install.sh
}
install_nvm

function install_node {
	nvm install --lts
	corepack enable && corepack prepare pnpm@latest --activate
	pnpm setup
}
install-node

function create_ssh_keys {
	echo -e "Please confirm defaults\n"
	# Generate Key
	ssh-keygen -f "$HOME"/.ssh/id_rsa

	# Start ssh-agent
	eval "$(ssh-agent -s)"

	# Add generated key to ssh agent
	ssh-add "$HOME"/.ssh/id_rsa
}
create_ssh_keys

function setupDocker {
	# Install prerequisites
	sudo apt-get install ca-certificates curl gnupg lsb-release aufs-tools cgroupfs-mount -y

	# Add GNU Privacy Guard Key
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	# Setup repository
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

	# Update Repository List
	sudo apt update

	# Install Docker
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
	exitCodeDockerInstall=$?
	verify_command "installing docker and addons" $exitCodeDockerInstall
}
setupDocker

function dockerUserConfiguration {
	sudo groupadd docker
	sudo usermod -aG docker "$USER"
}
dockerUserConfiguration

echo -e "\n${purple}Tasks${NC}\n\
  - Reboot to apply changes
  - Run zap update
  - Switch Keyboard Shurtcuts, (super for workspace overview)\n\
  - Update github ssh keys with, located in \$HOME/.ssh/id_rsa.pub
  - Adjust download folder in tools(browser) to downloads instead of Downloads
  - Use nvm to switch to desired node version
  - verify docker and node installations
  - adjust kitty configuration and set FiraCode as font
"

# TODO:
# - Install JulaMono
# - Load kitty config + kitty color scheme
# - Ensure node installs correctly
