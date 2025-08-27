#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

_single_file_set_artist_and_title(){

    if [ $# -ne 1 ] ; then
        echo "invalid number of arguments...
            Example of usage: set_mp3_metadata \"path/to/my - music to name.mp3\"">&2
        return 1
    fi

    local input="$1"
    local file="${input//\\}"    # remove backslashes
    local base=$(basename -- "$file")
    local name="${base%.*}"
    local ext="${base##*.}"

    if [ ! -f "$1" ] || [ "${ext}" != "mp3" ] ; then
        # not a mp3 file
        return 2
    fi
    
    dash_counter=$(echo "$name" | tr -cd '-' | wc -c)
    if [ $dash_counter -ne 1 ] ; then
        # doesn't have a single '-'
        return 3
    fi

    title=${name##*- }
    if [ ${#title} -eq ${#name} ] ; then
        # failed to find the title in a pattern \"artist - title\"
        return 4
    fi
    artist=${name% -*}
    if [ ${#artist} -eq ${#name} ] ; then
        # failed to find the artist in a pattern \"artist - title\"
        return 5
    fi
    
    id3v2 --song "$title" "$file"
    id3v2 --artist "$artist" "$file"
    
    return 0
}

set_artist_and_title() {
    for file in "$@"; do
        if ! $(_single_file_set_artist_and_title "$file") ; then
            echo -e "Failed to set metadata for ${RED}$file${NC}" >&2
        fi
    done
}