# @name Name Duplicate
# @brief The name of this artist might have been duplicated after the download, let's fix it.
# @description The filename follows the pattern `%(channel)s - %(title)s.%(ext)s`
#   which means that if the title of the video already contains the channel name,
#   the resulting filename will have the channel name duplicated.
#   This function set removes such duplications.

# description If the filename contains the artist name duplicated (e.g.,
#   "Artist - Artist - Song Title.mp3"), this function removes the duplication
#   to result in "Artist - Song Title.mp3".
# @arg $1 String The full path to the file to process.
# @example
#   _remove_artist_duplication "/path/to/Artist - Artist - Song Title.mp3
_remove_artist_duplication() {
    name=$(basename -- "$1")
    if [[ "$(_count_good_dashes "$name")" == "2" ]]; then
        new_name=$(echo "$name" | cut -d'-' -f1,3)
        mv -- "$1" "$(dirname -- "$1")/$new_name"
    fi
}

# @description For each provided path, the function checks if the filename
#   contains the artist name duplicated and removes the duplication if found.
# @arg $@ Files One or more paths to scan. Each argument should be a directory or file.
# @example
#   remove_artist_duplication_from_filenames "/path/to/Artist - Artist - Song Title.mp3" "/another/path/Artist - Song Title.mp3"
remove_artist_duplication_from_filenames() {
    for file in "$@"; do
        _remove_artist_duplication "$file"
    done
}