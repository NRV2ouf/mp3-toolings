#!/usr/bin/env bats

load '../mp3-metadata.sh'
load '../utils.sh'

teardown() {
    rm -rf "${BATS_TMPDIR}/*"
}

# _single_file_set_artist_and_title

@test "_single_file_set_artist_and_title - nominal" {
    file="${BATS_TMPDIR}/Artist - Title.mp3"
    touch "$file"
    run _single_file_set_artist_and_title "$file"
    [[ "$status" -eq 0 ]]

    title=$(id3v2 -R "$file" | awk -F': ' '/^TIT2/{print $2}')
    artist=$(id3v2 -R "$file" | awk -F': ' '/^TPE1/{print $2}')
    [[ "$title" == "Title" ]]
    [[ "$artist" == "Artist" ]]
}

@test "_single_file_set_artist_and_title - error on missing argument" {
    run _single_file_set_artist_and_title
    [[ "$status" -eq 1 ]]
}

@test "_single_file_set_artist_and_title - error not a mp3" {
    file="${BATS_TMPDIR}/Artist - Title.wav"
    touch "$file"
    run _single_file_set_artist_and_title "$file"
    [[ "$status" -eq 2 ]]
}

@test "_single_file_set_artist_and_title - error file doesn't exist" {
    file="${BATS_TMPDIR}/nonexistent.mp3"
    run _single_file_set_artist_and_title "$file"
    [[ "$status" -eq 2 ]]
}

@test "_single_file_set_artist_and_title - error no dash" {
    file="${BATS_TMPDIR}/Artist Title.mp3"
    touch "$file"
    run _single_file_set_artist_and_title "$file"
    [[ "$status" -eq 3 ]]
}

@test "_single_file_set_artist_and_title - error multiple dashes" {
    file="${BATS_TMPDIR}/Artist - Title - Extra.mp3"
    touch "$file"
    run _single_file_set_artist_and_title "$file"
    [[ "$status" -eq 3 ]]
}

@test "_single_file_set_artist_and_title - error no title" {
    file="${BATS_TMPDIR}/Artist -.mp3"
    touch "$file"
    run _single_file_set_artist_and_title "$file"
    echo "$status"
    [[ "$status" -eq 3 ]]
}

@test "_single_file_set_artist_and_title - error title lacking a space" {
    file="${BATS_TMPDIR}/Artist -Title.mp3"
    touch "$file"
    run _single_file_set_artist_and_title "$file"
    [[ "$status" -eq 3 ]]
}

@test "_single_file_set_artist_and_title - error no artist" {
    file="${BATS_TMPDIR}/- Title.mp3"
    touch "$file"
    run _single_file_set_artist_and_title "$file"
    [[ "$status" -eq 3 ]]
}

@test "_single_file_set_artist_and_title - error artist lacking a space" {
    file="${BATS_TMPDIR}/Artist- Title.mp3"
    touch "$file"
    run _single_file_set_artist_and_title "$file"
    [[ "$status" -eq 3 ]]
}

# set_artist_and_title

@test "set_artist_and_title - nominal" {
    file="${BATS_TMPDIR}/Artist - Title.mp3"
    touch "$file"

    run set_artist_and_title "$file"
    [[ "$status" -eq 0 ]]

    title=$(id3v2 -R "$file" | awk -F': ' '/^TIT2/{print $2}')
    artist=$(id3v2 -R "$file" | awk -F': ' '/^TPE1/{print $2}')
    [[ "$title" == "Title" ]]
    [[ "$artist" == "Artist" ]]
}

@test "set_artist_and_title - nominal 2 files" {
    file1="${BATS_TMPDIR}/Artist1 - Title1.mp3"
    file2="${BATS_TMPDIR}/Artist2 - Title2.mp3"
    touch "$file1" "$file2"

    run set_artist_and_title "$file1" "$file2"
    [[ "$status" -eq 0 ]]

    title1=$(id3v2 -R "${file1}" | awk -F': ' '/^TIT2/{print $2}')
    artist1=$(id3v2 -R "${file1}" | awk -F': ' '/^TPE1/{print $2}')
    [[ "$title1" == "Title1" ]]
    [[ "$artist1" == "Artist1" ]]

    title2=$(id3v2 -R "${file2}" | awk -F': ' '/^TIT2/{print $2}')
    artist2=$(id3v2 -R "${file2}" | awk -F': ' '/^TPE1/{print $2}')
    [[ "$title2" == "Title2" ]]
    [[ "$artist2" == "Artist2" ]]
}

@test "set_artist_and_title - nominal 2 files, one invalid" {
    file1="${BATS_TMPDIR}/Artist1 Title1.mp3"
    file2="${BATS_TMPDIR}/Artist2 - Title2.mp3"
    touch "$file1" "$file2"

    run set_artist_and_title "$file1" "$file2"
    [[ "$output" =~ "Failed" && "$output" =~ "$file1" ]]
    [[ "$status" -eq 0 ]]
    [[ -f "$file1" ]]
    [[ -f "$file2" ]]

    title2=$(id3v2 -R "${file2}" | awk -F': ' '/^TIT2/{print $2}')
    artist2=$(id3v2 -R "${file2}" | awk -F': ' '/^TPE1/{print $2}')
    [[ "$title2" == "Title2" ]]
    [[ "$artist2" == "Artist2" ]]
}

@test "set_artist_and_title - nominal idempotence" {
    file="${BATS_TMPDIR}/Artist - Title.mp3"
    touch "$file"

    run set_artist_and_title "$file"
    [[ "$status" -eq 0 ]]

    title=$(id3v2 -R "$file" | awk -F': ' '/^TIT2/{print $2}')
    artist=$(id3v2 -R "$file" | awk -F': ' '/^TPE1/{print $2}')
    [[ "$title" == "Title" ]]
    [[ "$artist" == "Artist" ]]

    run set_artist_and_title "$file"
    [[ "$status" -eq 0 ]]

    title=$(id3v2 -R "$file" | awk -F': ' '/^TIT2/{print $2}')
    artist=$(id3v2 -R "$file" | awk -F': ' '/^TPE1/{print $2}')
    [[ "$title" == "Title" ]]
    [[ "$artist" == "Artist" ]]
}

@test "set_artist_and_title - no files specified" {
    run set_artist_and_title
    [[ "$status" -eq 0 ]]
}

@test "set_artist_and_title - file doesn't exist" {
    file="${BATS_TMPDIR}/nonexistent.mp3"
    run set_artist_and_title "$file"
    [[ "$status" -eq 0 ]]
}

# _single_file_set_album

@test "_single_file_set_album - nominal" {
    album="AlbumName"
    filename="Artist - Title.mp3"
    file="${BATS_TMPDIR}/${album}/${filename}"
    mkdir -p "${BATS_TMPDIR}/${album}"
    touch "$file"

    run _single_file_set_album "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "$file" ]]

    set_album=$(id3v2 -R "$file" | awk -F': ' '/^TALB/{print $2}')
    [[ "$set_album" == "$album" ]]
}

@test "_single_file_set_album - nominal current directory" {
    album="AlbumName"
    filename="Artist - Title.mp3"
    file="${BATS_TMPDIR}/${album}/${filename}"
    mkdir -p "${BATS_TMPDIR}/${album}"
    touch "$file"


    cd "${BATS_TMPDIR}/${album}"

    run _single_file_set_album "$filename"
    [[ "$status" -eq 0 ]]
    [[ -f "$file" ]]

    set_album=$(id3v2 -R "$file" | awk -F': ' '/^TALB/{print $2}')
    [[ "$set_album" == "$album" ]]
}

@test "_single_file_set_album - nominal album has spaces" {
    album=Album\ Name\ With\ Spaces
    filename="Artist - Title.mp3"
    file="${BATS_TMPDIR}/${album}/${filename}"
    mkdir -p "${BATS_TMPDIR}/${album}"
    touch "$file"

    run _single_file_set_album "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "$file" ]]

    set_album=$(id3v2 -R "$file" | awk -F': ' '/^TALB/{print $2}')
    [[ "$set_album" == "$album" ]]
}

@test "_single_file_set_album - error on missing argument" {
    run _single_file_set_album
    [[ "$status" -eq 1 ]]
}

@test "_single_file_set_album - error not a mp3" {
    file="${BATS_TMPDIR}/AlbumName/Artist - Title.wav"
    mkdir -p "${BATS_TMPDIR}/AlbumName"
    touch "$file"
    run _single_file_set_album "$file"
    [[ "$status" -eq 1 ]]
}

@test "_single_file_set_album - error file doesn't exist" {
    file="${BATS_TMPDIR}/AlbumName/nonexistent.mp3"
    run _single_file_set_album "$file"
    [[ "$status" -eq 1 ]]
}

@test "set_album - nominal" {
    album="AlbumName"
    filename="Artist - Title.mp3"
    file="${BATS_TMPDIR}/${album}/${filename}"
    mkdir -p "${BATS_TMPDIR}/${album}"
    touch "$file"

    run set_album "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "$file" ]]

    set_album=$(id3v2 -R "$file" | awk -F': ' '/^TALB/{print $2}')
    [[ "$set_album" == "$album" ]]
}

@test "set_album - nominal no files specified" {
    run set_album
    [[ "$status" -eq 0 ]]
}

@test "set_album - nominal two files" {
    album1="AlbumName1"
    album2="AlbumName2"
    filename1="Artist1 - Title1.mp3"
    filename2="Artist2 - Title2.mp3"
    file1="${BATS_TMPDIR}/${album1}/${filename1}"
    file2="${BATS_TMPDIR}/${album2}/${filename2}"
    mkdir -p "${BATS_TMPDIR}/${album1}" "${BATS_TMPDIR}/${album2}"
    touch "$file1" "$file2"

    run set_album "$file1" "$file2"
    [[ "$status" -eq 0 ]]
    [[ -f "$file1" ]]
    [[ -f "$file2" ]]

    set_album1=$(id3v2 -R "$file1" | awk -F': ' '/^TALB/{print $2}')
    [[ "$set_album1" == "$album1" ]]

    set_album2=$(id3v2 -R "$file2" | awk -F': ' '/^TALB/{print $2}')
    [[ "$set_album2" == "$album2" ]]
}