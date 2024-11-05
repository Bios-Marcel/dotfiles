# Dotfiles

These are my dotfiles. They are made for Windows and Linux. Note that not all
tools might be configured on both systems.

On Linux, these will most likely be used alongside
[my NixOS configuration](https://github.com/bios-Marcel/nixos_config).

For Windows a convience bootstrap script is provided. Downloaded it via
powershell:

```powershell
Invoke-WebRequest "https://raw.githubusercontent.com/Bios-Marcel/dotfiles/refs/heads/master/setup.ps1" -OutFile setup.ps1
```

## Usage

Install [chezmoi](https://www.chezmoi.io/).

### Bootstrap a new machine:

```shell
chezmoi init
chezmoi cd
git remote add origin git@github.com:Bios-Marcel/dotfiles
git pull origin master
chezmoi apply
```

### Data

Default data is saved in [.chezmoi.toml](/.chezmoidata.toml). Override it with
`[data]` section in ``~/.config/chezmoi/chezmoi.toml`.

### Secret management

TODO

