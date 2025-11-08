#!/bin/bash

set -euo pipefail

source ./download.sh
source ./pair-remover.sh
source ./space-trimmer.sh
source ./folder.sh

PLAYLIST_URL="https://www.youtube.com/playlist?list=PLpygaDObWvmDCP60WIPCABhv_wACQ5ypG"

TMPDIR=$(download_mp3 "$PLAYLIST_URL")

echo "Processing files in $TMPDIR"

ls "$TMPDIR"

remove_brackets_from_filenames "$TMPDIR"/*

trim_spaces_from_filenames "$TMPDIR"/*

move_files_to_artist_folder "$TMPDIR"/*