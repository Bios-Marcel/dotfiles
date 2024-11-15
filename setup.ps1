# Make sure we can execute scripts.
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install package management facilities
if ($null -eq (Get-Command "scoop" -ErrorAction SilentlyContinue))
{
	Write-Host "Installing package manager ..."
	Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else
{
	Write-Host "Skipping package manager installation, already installed."
}

# Required to get dotfiles
scoop install git

if (!(Test-Path -Path "~/.local/share/chezmoi"))
{
	Write-Host "Downloading dotfiles ..."
	git clone "https://github.com/Bios-Marcel/dotfiles.git" "~/.local/share/chezmoi"
} else
{
	Write-Host "Skipping dotfiles download, already downloaded."
}

Write-Host "Installing tooling ..."

# Install all dependencies used in config
scoop bucket add extras
scoop bucket add java
scoop bucket add nerd-fonts
scoop bucket add sysinternals

# Core tooling, some might be installed already
scoop install 7zip chezmoi gpg

# OS stuff, useful for debugging and co.
scoop install gsudo process-explorer

# Useful terminal tooling
scoop install fzf ripgrep

# Default font used in config
scoop install IntelOneMono-NF

# Alternative terminal and shell
scoop install wezterm nu

# Tooling used for IDE
scoop install neovim python nodejs openjdk23 gradle maven gcc cmake

# Java dev env
scoop install idea visualvm openjdk21 openjdk22

# MISC
scoop install spotify sharex presenterm

# Config only for work
if ("$env:COMPUTERNAME" -eq "NB-00724")
{
	[Environment]::SetEnvironmentVariable('HOME','C:\Users\Schramm',[System.EnvironmentVariableTarget]::User)

	# Java dev env
	scoop install jmc tortoisesvn
	[Environment]::SetEnvironmentVariable('SVN_EXPERIMENTAL_COMMANDS','shelf3',[System.EnvironmentVariableTarget]::User)
	[Environment]::SetEnvironmentVariable('SVN_EDIETOR','nvim',[System.EnvironmentVariableTarget]::User)
}

# vi: ft=powershell
