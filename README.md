# Dotfiles

These are my dotfiles. They are made for Windows and Linux. Note that not all
tools might be configured on both systems.

On Linux, these will most likely be used alongside
[my NixOS configuration](https://github.com/bios-Marcel/nixos_config).

## Usage

Install [chezmoi](https://www.chezmoi.io/).

### Bootstrap a new machine:

```
chezmoi init
chezmoi cd
git remote add origin git@github.com:Bios-Marcel/dotfiles
git pull origin master
chezmoi apply
```

### Secret management

TODO

