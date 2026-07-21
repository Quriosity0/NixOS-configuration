# Quriosity's nixconf

![Lang](https://img.shields.io/github/languages/top/Quriosity0/nixconf)
![License](https://img.shields.io/github/license/Quriosity0/nixconf)
![Release](https://img.shields.io/github/v/release/Quriosity0/nixconf)
![GH-CI](https://img.shields.io/github/actions/workflow/status/Quriosity0/nixconf/nix-ci.yml)

My personal configuration files for **NixOS** Linux (system + Home manager, built with flakes)

## Requirements

- [NixOS](https://nixos.org/) ***unstable*** with flakes enabled
- [home-manager](https://github.com/nix-community/home-manager)

### NOTE!

Nix Flakes is an experimental feature. To enable flakes, when rebuilding system add `--experimental-features 'nix-command flakes'` flag. 

Unfree repository is disabled by default. To allow NixOS unfree packages, use NIXPKGS_ALLOW_UNFREE=1. 

Final command should look something like this

```nix
NIXPKGS_ALLOW_UNFREE=1 sudo nixos-rebuild switch --flake /path/to/nixconf#asuspc --experimental-features 'nix-command flakes'
```

## Installation and updating

### Installing

Clone the repo:

```bash
git clone https://github.com/Quriosity0/nixconf.git ~/nixconf
```

Apply system and Home manager configuration:

```bash
sudo nixos-rebuild switch --flake ~/nixconf#asuspc
home-manager switch --flake ~/nixconf#quriosity
```

If needed, clean old all generations:

```bash
sudo nix-collect-garbage -d
```
### Updating

When you want to update config to the latest commit, just do the pull inside the cloned folder and rerun all commands above (except git clone)

```bash
git pull
sudo nixos-rebuild switch --flake ~/nixconf#asuspc
home-manager switch --flake ~/nixconf#quriosity
```

> **NOTE:** `asuspc` & `quriosity` — names of my PC and profile, given in every configuration file in this repo. If you change them on your machine, then change them in this command

## Credits

**Thank you all for excelent work**

### flakes and their authors

[Nix by Eelco Dolstra](https://nixos.org/)

[Home manager by nix community](https://github.com/nix-community/home-manager)

[Millennium by Ethan Alexander(shdwmtr)](https://steambrew.app/)

[Spicetify-Nix by Gerg-L, the-argus and pietdevries94](https://github.com/Gerg-L/spicetify-nix)

[Hush by UMCEKO](https://github.com/UMCEKO/hush)

[nixcord by 4evy](https://github.com/4evy/nixcord)

[proxy-suite by FUFSoB](https://github.com/FUFSoB/proxy-suite-flake)

## Licnese

This project is freely distributed under the [GPL-3.0](LICENSE) license.
