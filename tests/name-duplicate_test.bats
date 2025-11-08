#!/usr/bin/env bats

load '../src/name-duplicate.sh'
load '../src/utils.sh'

## _remove_artist_duplication

@test "_remove_artist_duplication - nominal duplication" {
    file="${BATS_TEST_TMPDIR}/Channel - Artist - Title.mp3"
    touch "$file"
    run _remove_artist_duplication "$file"
    [[ "$status" -eq 0 ]]
    [[ ! -f "$file" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Channel - Title.mp3" ]]
}

@test "_remove_artist_duplication - no duplication" {
    file="${BATS_TEST_TMPDIR}/Channel - Title.mp3"
    touch "$file"
    run _remove_artist_duplication "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "$file" ]]
}

@test "_remove_artist_duplication - too many dashes" {
    file="${BATS_TEST_TMPDIR}/Channel - Arstist - Title - :man-shugging:.mp3"
    touch "$file"
    run _remove_artist_duplication "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "$file" ]]
}

## remove_artist_duplication_from_filenames

@test "remove_artist_duplication_from_filenames - multiple files" {
    file1="${BATS_TEST_TMPDIR}/Channel1 - Artist1 - Title1.mp3"
    file2="${BATS_TEST_TMPDIR}/Channel2 - Title2.mp3"
    file3="${BATS_TEST_TMPDIR}/Channel3 - Artist3 - Title3 - Lyrics.mp3"
    touch "$file1" "$file2" "$file3"
    run remove_artist_duplication_from_filenames "${BATS_TEST_TMPDIR}"/*.mp3
    [[ "$status" -eq 0 ]]
    [[ ! -f "$file1" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Channel1 - Title1.mp3" ]]
    [[ -f "$file2" ]]
    [[ -f "$file3" ]]
}

@test "remove_artist_duplication_from_filenames - no files" {
    run remove_artist_duplication_from_filenames "${BATS_TEST_TMPDIR}"/*.mp3
    [[ "$status" -eq 0 ]]
}