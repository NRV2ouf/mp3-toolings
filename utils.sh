# @name Utils
# @brief Utility functions for various tasks.
# @description This script contains a collection of utility functions that are 
#  usefull for other scripts.

# @description Counts the number of 'good' dashes (' - ') in the given string.
# @arg $1 String The input string to process.
# @stdout The count of dashes in the input string.
# @example
#   _count_dashes "artist - title - remix"
#   -> 2
_count_good_dashes(){
    echo "$1" | grep -o ' - ' | wc -l
}

# @description Extracts the title from a filename formatted as "artist - title".
# @arg $1 String The input filename.
# @stdout The extracted title, or an empty string if the format is incorrect.
# @example
#   _get_title "artist - title"
#   -> "title"
_get_title(){
    local name="$1"
    if [ "$(_count_good_dashes "$name")" -ne 1 ] ; then
        echo ""
        return 1
    fi
    echo "${name##*- }"
}

# @description Extracts the artist from a filename formatted as "artist - title".
# @arg $1 String The input filename.
# @stdout The extracted artist, or an empty string if the format is incorrect.
# @example
#   _get_artist "artist - title"
#   -> "artist"
_get_artist(){
    local name="$1"
    if [ "$(_count_good_dashes "$name")" -ne 1 ] ; then
        echo ""
        return 1
    fi
    echo "${name% -*}"
}