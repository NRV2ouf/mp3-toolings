# @name Folder
# @brief A set of functions to manage folders.
# @description A collection of commands to manage folders.

# @description Extracts the artist from a filename and creates a folder
#   named after the artist in the same directory as the file, then moves the
#   file into that folder.
# @arg $1 filepath The path to the mp3 file.
# @exitcode 0 if the operation was successful,
# @exitcode 1 if the file argument is invalid,
# @exitcode 2 if the artist could not be extracted from the filename.
# @example
#   _create_and_move_to_folder_from_artist "path/to/artist - title.mp3"
_create_and_move_to_folder_from_artist(){
    local path
    if [[ -z "$1" || ! -f "$1" ]] ; then
        echo "file invalid" >&2
        return 1
    fi
    path=$(dirname -- "$1")
    if ! artist=$(_get_artist "$1") ; then
        echo "failed to extract artist from '$1'" >&2
        return 2
    fi
    mkdir -p "${path}/${artist}"
    mv "$1" "${path}/${artist}/"
}

# @description Moves each provided files of the right format into a folder named
#   after the artist, creating the folder if it does not exist.
# @details This function iterates over each provided file path and calls the
#   helper function `_create_and_move_to_folder_from_artist` to perform the move. If
#   the move operation fails for any file, it prints an error message to
#   standard error.
# @arg $@ files One or more paths to mp3 files.
# @example
#   move_files_to_artist_folder "path/to/artist1 - title1.mp3" "path/to/artist2 - title2.mp3"
move_files_to_artist_folder(){
    for file in "$@"; do
        if ! _create_and_move_to_folder_from_artist "$file" ; then
            echo -e "Failed to move ${RED}$file${NC}" >&2
        fi
    done
}