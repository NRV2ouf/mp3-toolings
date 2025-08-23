#!/bin/bash

set_mp3_metadata(){

    if [ $# -ne 1 ] ; then
        echo "invalid number of arguments...
            Example of usage: $0 \"path/to/my - music to name.mp3\"">&2
        return 1
    fi

    local input="$1"
    local file="${input//\\}"    # remove backslashes
    local filename="${file##*/}"
    local name="${filename%.*}"
    local ext="${filename##*.}"

    if [ "$ext" != "mp3" ]; then
        echo "$file is not a mp3 ; skipping...">&2
        return 2
    fi

    dash_counter=$(echo "$name" | tr -cd '-' | wc -c)
    if [ $dash_counter -ne 1 ] ; then
        echo "$filename doesn't have a single '-' ; skipping...">&2
        return 3
    fi

    title=${name##*- }
    if [ ${#title} -eq ${#name} ] ; then
        echo "failed to find the title in a pattern \"artist - title\" ; skipping...">&2
        return 4
    fi
    artist=${name% -*}
    if [ ${#artist} -eq ${#name} ] ; then
        echo "failed to find the artist in a pattern \"artist - title\" ; skipping...">&2
        return 5
    fi
    
    id3v2 --song "$title" "$file"
    id3v2 --artist "$artist" "$file"
    
    echo "Metadata set for $file"
    return 0
}
