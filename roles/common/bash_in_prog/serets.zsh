echo "$(tput setaf 6)"settings secrets to env from home/secrets"$(tput sgr0)"
# Create files in ~/
# LANDSCAPE_API_KEY=DFKDJFOSJDOF
# LANDSCAPE_API_SECRET=DFJSDOFIJOSIDJFOIDWJ
for file in ~/secrets/*.env.local; do
    # echo "$(tput setaf 6)"Settings env variables from LANDSCAPE_API.evn.local"$(tput sgr0)"

    echo "$(tput setaf 6)"loading env variables from ${file}"$(tput setaf 6)"
    source "${file}"

done
