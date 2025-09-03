# @name Mp3 Metadata
# @brief A set of functions to set some MP3 metadata based on the filename based 
# on pattern different patterns.
# @description This script defines a function `set_artist_and_title`
#  that takes one or more mp3 file paths as arguments. It scans each
#  filename for known patterns (like "artist - title") and sets the artists and 
#  title ID3v2 tags accordingly.
# @TODO: add more patterns

RED='\033[0;31m'
NC='\033[0m'

# @description A helper function that sets the artist and title metadata for a 
#   single mp3 file based on the filename pattern "artist - title".
# @details This function extracts the artist and title from the filename by 
# splitting at the first occurrence of ' - '. It then uses the `id3v2` command 
# to set the corresponding ID3v2 tags in the mp3 file.
# @arg $1 filepath The path to the mp3 file.
# @exitcode 0 if the metadata was successfully set,
# @exitcode 1 if the number of arguments is incorrect,
# @exitcode 2 if the file is not a valid mp3 file,
# @exitcode 3 if the filename does not match the expected pattern: "artist - title".,
# @example
#   _single_file_set_artist_and_title "path/to/artist - title.mp3"
_single_file_set_artist_and_title(){

    if [ $# -ne 1 ] ; then
        echo "invalid number of arguments...
            Example of usage: set_mp3_metadata \"path/to/my - music to name.mp3\"">&2
        return 1
    fi

    local file
    local base
    local name
    local ext
    
    file="${1//\\}"    # remove backslashes
    base=$(basename -- "$file")
    name="${base%.*}"
    ext="${base##*.}"

    if [ ! -f "$1" ] || [ "$ext" != "mp3" ] ; then
        # not a mp3 file
        return 2
    fi

    local title
    local artist
    if ! title=$(_get_title "$name") || ! artist=$(_get_artist "$name") ; then
        return 3
    fi
    
    id3v2 --song "$title" "$file"
    id3v2 --artist "$artist" "$file"
    
    return 0
}

# @description Sets the artist and title metadata for each provided mp3 file
#   based on the filename pattern "artist - title".
# @details This function iterates over each provided file path and calls the
#   helper function `_single_file_set_artist_and_title` to set the metadata. If
#   the metadata setting fails for any file, it prints an error message to
#   standard error.
# @arg $@ files One or more paths to mp3 files.
# @example
#   set_artist_and_title "path/to/artist1 - title1.mp3" "path/to/artist2 - title2.mp3"
set_artist_and_title() {
    for file in "$@"; do
        if ! _single_file_set_artist_and_title "$file" ; then
            echo -e "Failed to set metadata for ${RED}$file${NC}" >&2
        fi
    done
}

# @description A helper function that sets the album metadata for a single mp3
#   file based on its parent directory name.
# @details This function extracts the album name from the parent directory of
#  the mp3 file. If the file is in the current directory, it uses the current
#  directory name as the album name. It then uses the `id3v2` command to set
#  the album ID3v2 tag in the mp3 file.
# @arg $1 filepath The path to the mp3 file.
# @exitcode 0 if the album was successfully set,
# @exitcode 1 if the file is not a valid mp3 file.
# @example
#   _single_file_set_album "path/to/AlbumName/artist - title.mp3
_single_file_set_album() {
    if [ ! -f "$1" ] || [ "${1##*.}" != "mp3" ] ; then
        # not a mp3 file
        return 1
    fi

    local path
    path=$(dirname -- "$1")
    dirname=$(basename -- "$path")

    if [ "$dirname" == "." ] ; then
        dirname=${PWD##*/}
    fi

    album="${dirname//\\}"    # remove backslashes
    id3v2 --album "$album" "$1"
}

# @description Sets the album metadata for each provided mp3 file based on its
#   parent directory name.
# @details This function iterates over each provided file path and calls the
#   helper function `_single_file_set_album` to set the album metadata. If the
#   album setting fails for any file, it prints an error message to standard
#   error.
# @arg $@ files One or more paths to mp3 files.
# @example
#   set_album "path/to/AlbumName/*.mp3"
set_album() {
    for file in "$@"; do
        if ! _single_file_set_album "$file" ; then
            echo -e "Failed to set album for ${RED}$file${NC}" >&2
        fi
    done
}