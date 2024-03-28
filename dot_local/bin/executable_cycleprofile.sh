function activate() {
  echo "$1"
  powerprofilesctl set "$1"
  exit 0
}

profiles=($(powerprofilesctl list | rg --multiline '[ *] ([a-z\-]+):' -r '$1'))
current=$(powerprofilesctl get)

use_next=false
for profile in ${profiles[@]}; do
  if [ "$use_next" = true ]; then
    activate $profile
  fi

  if [ "$current" = "$profile" ]; then
    use_next=true
  fi
done

activate ${profiles[0]}

