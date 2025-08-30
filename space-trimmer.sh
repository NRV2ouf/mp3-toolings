# @name Space Trimmer
# @brief Trims superfluous spaces from filenames.
# @description Trims leading, trailing, and multiple consecutive spaces.

# @description Replaces multiple consecutive spaces with a single space.
# @arg $1 The string to process.
_trim_multi_spaces(){
    echo "$1" | sed -E 's/  +/ /g'
}

# @description Trims leading and trailing spaces from a string.
# @arg $1 The string to process.
_trim_leading_and_trailing_spaces(){
    echo "$1" | sed -E 's/^ +| +$//g'
}

# @description Trims leading, trailing, and multiple consecutive spaces from filenames.
# @arg $@ List of filenames to process.
# @example
#   trim_spaces_from_filenames "  example  file  name.txt  " " another   file.txt "
trim_spaces_from_filenames(){
    local file path filename
    for file in "$@"; do
        path=$(dirname -- "$file")
        filename=$(basename -- "$file")
        filename="$(_trim_multi_spaces "$filename")"
        filename="$(_trim_leading_and_trailing_spaces "$filename")"
        if [ "$(basename -- "$file")" != "$filename" ]; then
            mv -v -- "$file" "${path}/${filename}"
        fi
    done
}