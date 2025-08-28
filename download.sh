#!/bin/bash

# @name Download
# @brief A set of functions to download mp3 or mp4 from a url using yt-dlp.
# @description This script defines two functions `download_mp3` and `download_mp4`
#   that take a url as argument. This URL can be a single video or a playlist.
#   The functions use yt-dlp to download the audio as mp3 or video as mp4,
#   respectively, and save them in a temporary folder in ~/Music or ~/Videos.
#
#   This requires yt-dlp to be installed and available in the system's PATH.

if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp could not be found, please install it." >&2
    return 1 2>/dev/null || exit 1
fi

# @name download_mp3
# @description Downloads audio from the provided URL and saves it as mp3 files.
# @details This function uses yt-dlp to extract audio from the given URL,
#   convert it to mp3 format, and save it in a temporary folder within ~/Music.
#   It also embeds thumbnails and metadata into the mp3 files.
# @arg $1 url The URL of the video or playlist to download.
# @example
#   download_mp3 "https://www.youtube.com/watch?v=example"
download_mp3(){
    url=$1
    tmp_folder=$(mktemp -d ~/Music/tmp.XXXXXX)

    yt-dlp \
        -x --audio-format mp3 \
        --cookies-from-browser firefox \
        --embed-thumbnail --add-metadata --embed-metadata \
        --output "$tmp_folder/%(title)s.%(ext)s" \
        "$url"

    echo -e "\e[34mDownloaded to $tmp_folder\e[0m"
}

# @name download_mp4
# @description Downloads video from the provided URL and saves it as mp4 files.
# @details This function uses yt-dlp to download the best quality video and audio
#   from the given URL, merges them into mp4 format, and saves them in a temporary
#   folder within ~/Videos. It also embeds thumbnails and metadata into the mp4 files.
# @arg $1 url The URL of the video or playlist to download.
# @example
#   download_mp4 "https://www.youtube.com/watch?v=example"
download_mp4() {
    url=$1
    tmp_folder=$(mktemp -d ~/Videos/tmp.XXXXXX)

    yt-dlp \
        --cookies-from-browser firefox \
        -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' \
        --merge-output-format mp4 \
        --embed-thumbnail --add-metadata --embed-metadata \
        --output "$tmp_folder/%(title)s.%(ext)s" \
        "$url"

    echo -e "\e[34mDownloaded to $tmp_folder\e[0m"
}
