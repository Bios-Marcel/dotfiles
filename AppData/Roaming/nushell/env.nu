def create_left_prompt [] {
    let path_segment = ($env.PWD)

    $path_segment
}
$env.PROMPT_COMMAND = { create_left_prompt }
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense,powershell,cobra' # optional
mkdir ~/AppData/Local/carapace
carapace _carapace nushell | save --force ~/AppData/Local/carapace/init.nu
