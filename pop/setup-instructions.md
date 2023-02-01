# Setup Instructions

## GUI Settings

- switch shortcuts
- super for workspace overview

## System Configuration

To make setup easy, you can use my prototype setup scripts (not maintained actively)

Clone the 'dotfiles' repository, you can remove it after making use of the available scripts.

```bash
git clone https://github.com/zettlrobert/dotfiles.git
```

First we navigate to the `dotfiles/scripts/setup` directory and execute the following script in order.

To setup a (subjectively improved)default directory structure for our user account. It also removes the capitalized default directories and updates the desktop environment to point to the newly created directories

```bash
# Assuming you are in the direcotry of the script
./setup-home-structure.sh
```

The next script is for installing a few default packages which I find useful, you might want to tweak the array of packages before executing

```bash
# Assuming you are in the direcotry of the script
./setup-default-packages.sh
```

The next step is to change our default user shell to `zsh` and configure it
Install zsh

```bash
sudo apt install zsh
```

Check if the binary is available and with which path

```bash
cat /etc/shells
```

Update the shell with the `chsh` command according to the path form the above command (propably `/bin/zsh`)

```bash
chsh -s /bin/zsh
```

Relog or Reboot your System!
Optially call Extensions with the launcher and disable Desktop Icons (I hate them)

Now it is time to configure zsh, i recently switched to zap-zsh and therefore will also use that here, alternatiely you can use oh-my-zsh

Install [zsh-zap](https://github.com/zap-zsh/zap)

```bash
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
```

Base configruation to overwrite .zshrc be sure to double check the plugins (vim is tricky)

```bash
# Source ZAP
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# Source fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Example install plugins
plug "zap-zsh/supercharge"
plug "zap-zsh/vim"
plug "zap-zsh/fzf"
plug "Aloxaf/fzf-tab"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"

# Example install completion
plug "esc/conda-zsh-completion"

# My Prompt
plug "zettlrobert/simple-prompt"

# Defaults
export EDITOR=nvim
```

Source and shell configuraiton and install zap plugins

```bash
source ~/.zshrc
zap update
```

Finally (this could very well be the first step)let's continue with some development prerequesites
Check and update to latest version of git

```bash
sudo add-apt-repository ppa:git-core/ppa

sudo apt update

sudo apt install git
```

Configure your system with the right git defaults either edit `.gitconfig` in your home directory or use the following commands to set some defaults

```bash
# Replace with the name that should be associated with the code
git config --global user.name "FIRST_NAME LAST_NAME"

# Replace with the name that should be associated with the code
git config --global user.email "name@example.com"
```

## Setup ssh and add key to github

Generate key with

```bash
ssh-keygen
```

Start ssh-agent

```bash
eval "$(ssh-agent -s)"
```

Add key to the ssh agent

```bash
ssh-add ~/.ssh/id_rsa
```

## Setup Node Version Manager and Node

Install Node Version Manager to have an easy time switching between different node versions.
The version you install now will be the default nvm references, to change that refer to the nvm manual

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.zshrc
nvm install node
```

Gloally activate pnpm

```bash
corepack enable && corepack prepare pnpm@latest --activate
```

Configure the gloal store and add it to the path

```bash
pnpm setup
```

## Btm

Install btm, an improved top

```bash
# This has to be updated curl latest release and install it
# - `curl -LO https://github.com/ClementTsang/bottom/releases/download/0.8.0/bottom_0.8.0_amd64.deb sudo dpkg -i bottom_0.8.0_amd64.deb`
# - `rm bottom_0.8.0_amd64.deb`
```

## Useful Aliases

```bash
# Bat package name is already used so bat is batcat -> we alias it
echo "alias bat='batcat'" >> .zshrc

# Pretty list with everything in directory
echo "alias ll='exa --icons --long -a --group --header --bytes'" >> .zshrc

# Pretty file output
echo "alias lexa='exa --icons --long -a --group --header --bytes'"  >> .zshrc

# Copy current path to clipboard (xclip) required
echo "alias ypp='pwd | xclip -selection clipboard'" >> .zshrc

# Git Aliases
echo "alias pretty-git-log='git log --pretty=oneline --graph --decorate --all'" >> .zshrc
echo "alias gdiff='git diff | batcat'" >> .zshrc

# Fzf with preview
echo "alias fzfp="fzf --preview 'bat --color=always {}'"" >> .zshrc
```

## Docker

Docker can be setup in multiple ways, refer to the offical instructions on how to install docker and which post installation setps (running without root privileges) are recommended

Install prerequesites

```bash
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

Add official Docker GPG Key

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Setup the Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

If there are GPG errors when updating the repository list, double check with the installation instructions on the official page

```bash
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

To use docker as a non root user, we have to create the docker group and add our user to it, after the user is added we have to relog to apply the changes

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

### Gnome Extensions

I like to customize my default gnome experience a bit, therefore i install some gnome-extensions

- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
- [Clipboard Indicator](https://extensions.gnome.org/extension/779/clipboard-indicator/)
- [Easy Docker Containers](https://extensions.gnome.org/extension/2224/easy-docker-containers/)

To change a theme download it, place it in `/usr/share/themes` and change it with the tweaks application

## Install Nix Package Manager

This is something i will try out in the future, as i will probably switch to nix os in the long run.
Just leaving a note here that some packages will be installed via nix, especially if they are not 'core' packages like the above.
