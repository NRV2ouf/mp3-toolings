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
