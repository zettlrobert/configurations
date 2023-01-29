# NixOS Basics

- [NixOS](https://nixos.org/download.html)
- [Manual](https://nixos.org/download.html#nix-more)
- [Unstable](https://releases.nixos.org/?prefix=nix)

## Getting Started

### Installation

- burn iso to usb stick
- boot from usb
- configure nix as root user

#### Partitions

Gparted:

- Device -> Create partitoin table -> gpt (uefi boot)
- Add new partiton -> fileSystem: ext4/linux-swap
- Manage flags -> boot for ext4
- Label partitions (useful later)

Parted:
It is important to get the right disk!

- parted /dev/sda -- mklabel gpt
- parted /dev/sda -- mkpart primary 512MiB - -8GiB
- parted /dev/sda -- mkpart primary linux-swap -8Gib 100%

- parted /dev/sda -- mkpart ESP fat32 1Mib 5120Mib
- parted /dev/sda -- set 3 esp on

- mkfs.ext4 -L nixos /dev/sda1
- mkswap -L swap /dev/sda2

- mkfs.fat -F 32 -n boot /dev/sda3

Mount disk

- mount /dev/disk/by-label/nixos /mnt
- mount /dev/disk/by-label/boot /mnt/boot
- swapon /dev/sda2

### Initial Configuration

Write to documents into `/mnt`
`nixos-generate-config --root /mnt`

**configuration.nix**:
This file defines what should be installedo n the system.

This are the arguments, which are used in the system (the three dots indicate everything else that is requ
ired)
`{ config, pkgs, ... }`

In imports we import the second generated file, hardware-configuration
`imports`

#### Boot Options

Legacy
Default Grub setup:
`boot.loader.grub.enable = true;`
`boot.loader.grub.version. = 2;`
`boot.loader.grub.device = /dev/sda;`
Dual booting made easy
`boot.loader.grub.useOSProber = true`
Dual boot advanced (look at documentation)
`boot.loade.grub.extraEntries = ...`

UEFI
Default UEFI setup
`boot.loader.systemd-boot.enable = true` -- this can be deleted if dual booting with grub
`boot.loader.efi.canTouchEfiVariables = true`

Dual booting using grub

```nix
boot.loader = {
efi = {
  canTouchEfiVariables = true,
  efiSysMountPoint = "/boot/efi"
};
 grub = {
   enable = true
   devices = ["nodev"]
   efiSupport = true
   useOSProber = true -- will not find windows partiton, will find the windows partition when system is bu
ilt
 }
}
```

```nix
boot = {
  kernelPackages = pkgs.linuxPackages_latest; -- always get latest kernel
  initrd.kernelModules = ["amdgpu"] -- graphics card module / look up for nvidea
  loader = {
    configurationLimit = 5 -- limit the amount of generations
    timeout = 5;
  }
}
```

- Log in with the initialPassword
- via TTY --> `<ctrl + alt + f1>` --> back to login screen `<ctrl + alt + f7`

### Install packages

- Configuration file: `/etc/nixos/configuration.nix` to add to systemPackages -> `sudo nixos-rebuld switch `
- individually via Nix Package Manager:
  - install: `nix-env -iA nixos.<package>`
  - list: `nix-env -q`
  - unisntall: `nix-env --uninstall <package>`

For 'unfree' packages we have to set an environment variable: `NIXPKGS_ALLO_UNFREE=1`, or add an additonal
configuration

- `nixpkgs.config.allowUnfree = true`

Something to keep in mind some packages are services, and they need to be installed accordingly.

- `services.<package>.enabled = true`

### Variables

On the very top, beneath argument declaration variables can be declared

```nix
let
  user="robert"
in
```

Variables can be used via `${user}`

### Overlays

Overlays are Nix functions which accept two arguments, conventionally called self and super, and return a
set of packages
An Overlay changes attributes and overlays the 'main' package

Example Overlay to update discord with the latest version

```nix
nixpkgs.overlays = [
  (self: super: {
    discord = super.discord.overrideAttrs (
      _: {
        src = builtins.fetchTarball {
          url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        }
      };
    )
  })
]
```

## Updating & Upgrading

Nix-channel

- example: `nix-channel --add https://nixos.org/channels/nixos-21.11`
- update `nix-channel --update`
- `sudo nixos-rebuild switch --upgrade`

Auto upgrade system

```nix
system.autoUpgrade = {
  enable = true;
  channel = "https://nixos.org/channels/nixos-unstable"
}
```

### Garbage Collection

Remove undeclared packaged, dependencies and symlinks:

- `nix-collect-garbage`

Remove above of older generations:

- `nix-collect-garbage --delete-pld`

List generations:

- `nix-env --list-generations`

Remove specific generations or older than ... days:

- `nix-env --delete-generatons 14d`
- `nix-env --delete-generations 10 11`

Optimize store:

- `nix-store --gc`

All in one:

- `nix-collect-garbage -d`
