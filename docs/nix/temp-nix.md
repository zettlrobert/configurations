# Nix

## Nix Flakes

### Inputs

Define links to other flakes or package repositories.

When nix evaluation command is run, nix will create a flake.lock in the location

All flakes will have an independent version and with the flake lock consistency across versions is available.

### Outputs

Do whatever you did in a regular nix file

after outputs we can define variabls with `let` `in` syntax, can later be accessed with `${}`

The following configuariton is comparable to a lua table.

If we provide a name the name has to be provided when executing the flake

To update a flake run `nix flake update` will pull all new versions of all dependencies.

## Nix home-manager

- can be a user installation
- can be installed as a module

### NixOS option

- home-manager package needs to be installed (configuration.nix pkgs.home-manager)

- `nix-whell -p home-manager`

- `home-manager init` generates a `falke.nix` and a `home.nix` file

Home Manger get's a dedicated input and follows nixpkgs -> will follow the same git revision as the rest of the file

- nees a relative refernce to the regular nix files

- `home-manager switch` or `home-manager switch --flake ~/.config/home/<user>` applies the configuration

### Home Manager as a Module

- home-manager will be rebuild with the system
- no sudoless rebuild
- needs to be rebuilt for other distros

### Home Nix File

- requires username, homeDirectory `home.username`
- the users packages
- the environment variables
- `home.file` can link files from nix store to home directory
- home.stateVersion
- `man home-configuration.nix`
- examples
  - programs.git - don't configure git over and over again
  - programs.gtk - don't theme again and again
  - xdg.mimeApps.defaultApplications - default for all types of file
    ```bash
        "text/plain" = [ "neovide.desktop" ];
        "application/pdf" = [ "zathura.desktop" ];
        "video/*" = ["mpv.desktop"]
    ```
- dotfiles into nix
- nix-colors to ensure the same coloring for everything

## Nix and Hyprland

- `NIXOS_OZONE_WL = "1"`
- research `opengl`
- `programs.hyprland.xwayland.enable` to run xserver based software

- `waybar` / `eww` for bar
- `dunst` / `mako` notification daomon
- `libnotify` - dependency for notification daemon
- `xdg.portal.enable` portal for screen sharign
- `xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];` handle link, file openign etc...
- `sound.enable = true`
- `security.rtkit.enable = true;`
-

```nix
services.pipewire = { # pipewire is also reqwiured for screensharing
    enable=true
    alsa.enalbe = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
}
```

- `hyprpaper/swaybg/wpapered/mpvpaper/swww` for wallpaper
- kitty
- `rofi-wayland` / `wofi` / `bemenu` `fuzzel` `toffi`
- use `exec-once=bash ~/.config/hypr/start.sh` to execute startup script once

- initialize wallpaper daemon, notification daemon, set wallpaper, `nm-applet` --> `nm-applet --indicator &`
  `#!/usr/bin/env/ bash` as there is no defautl bash in /bin
- `super + m` restarts hyprland?
- tweak waybar

#### Screenshots

screenshot desktop with selection
`grim -l 0 -g "$(slurp)" - | wl-copy

pkgs.grim - screenshot utility
pkgs.slurp - select utility
pkgs.wl-copy - xclip alternative

## Nix Way to write Scripts

- `writeShellScriptBin`

  - creates shell script in nix store
  - makes it executable
  - returns path

- function that takes pkgs as input and returns an output

```nix
{ pkgs }:
    pkgs.writeShellScriptBin "my-awesome-script" ''
        echo "hello worl" | ${pkgs.cowsay}/bin/cowsay | ${pkgs.lolcat}/bin/lolcat
```

- easy methods to find binary for packag
- use nix indexpackage to locate every file
- use nix-index-database to look up

- to make the script avaialabe we need to import it into our `configuration.nix` it needs to inherit pkgs (as we reference them in the script)
- inport can either be direclty imported or be imported in the variables

## Nix: Sddm, Gtk, QT5 Theming

- theming is accomplished with theming
- gtk(gnome) and qt(kde) are the two frameworks used for theming
- in `home.nix` - `gtk.enable = true;` / `qt.enable = true;`
- in qt.sty.e.name = 'theme-name'

- gtk themes are more in depth

```nix
gtk.cursorTheme.package = pkgs.bibata-cursors;
gtk.cursorTheme.name = "Bibata-Modern-Ice";

gtk.theme.package = pkgs.adw-gtk3;
gtk.theme.namee = "adw-gtk3";

gtk.iconTheme.package = gruvboxPlus;
gtk.iconTheme.name = "GruvboxPlus";
```

- with a more traditonal aproach we can also define them in home.file set

```nix
".icons/bibata".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic";

# both cases need a declarative approach
```

- package icon packs

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation {
    name = "gruvbox-plus";

    src = pkgs.fetchurl {
        url = "https://github.com/SylEleuth/gruvbox-plus-icon-pack/releaes/.../pack.zip";
        # run with a fake one, take the correct one from the error
        sha = "0000000000000000000000000000000000000000000000000000";
    }

dontUnpack = true;

installPhase = ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip $src -d $out/
'';
}
```

- `nix-prefetch-url "https://some-url"` can be used to fetch a sha from any remote

- sddm theming

```nix
{ pkgs }:

pkgs.stdenv.mkDerivation
    name = "sddm-theme";
    src = pkgs.fetchFromGitHub {
        owner = "MarianArlt";
        repo = "sddm-sugar-dark";
        rev = "asdfasdfasdfasfsadfasdfasdfasdfsaf";
        sha256 = "asdfasdf123adf123adfvasdfasdfasf123asdfasdf"
    };
installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
'';
}
```

- in configration.nix we can define theme

```nix
services.xserver = {
    enable = true;
    displayManager = {
        sddm.enable = true;
        sddm.theme = "${import ./sddm-theme.nix { inherit pkgs; }}";
    };
};
```

- in variables we can import or define new values like images
- these values can be applied in the installPhase and overrite the 'packaged' default values

## Nix Dev Environments

Development Environments for each Project, depedencies in a list without polluting the user space

- create `shell.nix` files
- should contain a function that takes a set with nix packages
- can be provided by calling function or taken from system channels
- retuns `mkshell` and retuns output with set of packages
- can be added to falke.nix files by importing it from relative path or
- declaring it in the systems devshell default configuration key
- run `nix develop` to start environment
- `nativeBuildInputs` - add package to have dependency availalbe
- `nix develop --command zsh` to drop into custom shell with own alias availalbe
- add `shellHook` to execute various scripts
- we can declare specific versions of packags with nix flakes
- quick shell on non-flake `nix-shell -p python3`
- `nix shell nixpkgs#python3` to have a quick shell with flakes

## Declaring firefox with nix

Firefox can be declared, extensions configured with special inputs

vim like firefox [tridactyl](https://github.com/tridactyl/tridactyl)

## Xremap with Nix

[Xremap](https://github.com/k0kubun/xremap)

### Xremap

- create a config.yml file (does not have a standart direcotry)

```yml
modmap:
  - name: main remaps
    remap:
      CapsLock:
        held: leftctrl
        alone: esc
        alone_timeout_millis: 150
```
- to execute `sudo xremap <path/to/file>`
- per application rebinds

#### Installation

- add url to flake input 
- make sure @inputs: is appended to outputs to have all inputs availalbe
- pass inputs to nixos configuration by inheriting inputs in the specialArgs  
- in nixconfig add the improts `inputs.xremap-flake.nikxosModules.default`
- define the `services.xremap` configuration

- with home manager
- include into flake 

```nix
hardwaree.uinput.enable = true;
users.groups.uinput.members = ["yurii"];
users.groups.input.members = ["yurii"];
```

-  in home manager falke pass inputs to home manager


### Nix Colors

https://www.youtube.com/watch?v=jO2o0IN0LPE&list=PLko9chwSoP-15ZtZxu64k_CuTzXrFpxPE&index=10

- base16 is a project meant to simplify theming for linux distributions
- nix colors provides the color codes of base16 to make the colors available
- install nix colors as a flake
- include nix-colors in inputs
- expose entire inputs to outputs
- ad dinputs into home manager inputs
- now acess to all themes is given
- select a color theme by ` colorScheme =inputs.nix-colors.colorSchemes.gruvbox-dark-medium;`
- now modules can be imported into a directory
- modules now take config as an input that provides paraemters form main configuraiton file













