# MP3-Toolings

## Brief

A set of functions designed to:
1. Download mp3 files from Youtube.
2. Format their name.
3. Set their metadata.
4. Sort them.

## Requirements

- bash ≥ 4.0
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) to download videos from Youtube
    - `sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && sudo chmod a+rx /usr/local/bin/yt-dlp`
- [id3v2](https://github.com/myers/id3v2) to set metadata of mp3 files
    - `sudo apt install id3v2`
- (Optionnal) [bats](https://github.com/bats-core/bats-core)
    - `sudo apt install bats`
    - For testing purposes only