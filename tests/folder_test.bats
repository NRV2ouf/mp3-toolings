#!/usr/bin/env bats

load '../utils.sh'
load '../folder.sh'

teardown() {
    rm -rf "${BATS_TEST_TMPDIR:?}/"*
}

# _create_and_move_to_folder_from_artist

@test "_create_and_move_to_folder_from_artist - nominal" {
    file="${BATS_TEST_TMPDIR}/Artist - Title.mp3"
    touch "$file"
    run _create_and_move_to_folder_from_artist "$file"
    [[ "$status" -eq 0 ]]
    [[ ! -f "${BATS_TEST_TMPDIR}/Artist - Title.mp3" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Artist/Artist - Title.mp3" ]]
}

@test "_create_and_move_to_folder_from_artist - nominal folder already exists" {
    file="${BATS_TEST_TMPDIR}/Artist - Title.mp3"
    mkdir -p "${BATS_TEST_TMPDIR}/Artist"
    touch "$file"
    run _create_and_move_to_folder_from_artist "$file"
    [[ "$status" -eq 0 ]]
    [[ ! -f "${BATS_TEST_TMPDIR}/Artist - Title.mp3" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Artist/Artist - Title.mp3" ]]
}

@test "_create_and_move_to_folder_from_artist - no argument" {
    run _create_and_move_to_folder_from_artist
    [[ "$status" -eq 1 ]]
    [[ "$output" == "file invalid" ]]
}

@test "_create_and_move_to_folder_from_artist - file doesn't exist" {
    rm -rf "${BATS_TEST_TMPDIR}/*"
    file="${BATS_TEST_TMPDIR}/Artist - Title.mp3"
    run _create_and_move_to_folder_from_artist "$file"
    [[ "$status" -ne 0 ]]
    [[ ! -f "${BATS_TEST_TMPDIR}/Artist/Artist - Title.mp3" ]]
}

@test "_create_and_move_to_folder_from_artist - invalid filename" {
    file="${BATS_TEST_TMPDIR}/InvalidFilename.mp3"
    touch "$file"
    run _create_and_move_to_folder_from_artist "$file"
    [[ "$status" -ne 0 ]]
    [[ -f "${BATS_TEST_TMPDIR}/InvalidFilename.mp3" ]]
}

# move_files_to_artist_folder

@test "move_files_to_artist_folder - nominal" {
    file1="${BATS_TEST_TMPDIR}/Artist1 - Title1.mp3"
    file2="${BATS_TEST_TMPDIR}/Artist2 - Title2.mp3"
    touch "$file1" "$file2"
    run move_files_to_artist_folder "${BATS_TEST_TMPDIR}"/*.mp3
    [[ "$status" -eq 0 ]]
    [[ ! -f "${BATS_TEST_TMPDIR}/Artist1 - Title1.mp3" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Artist1/Artist1 - Title1.mp3" ]]
    [[ ! -f "${BATS_TEST_TMPDIR}/Artist2 - Title2.mp3" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Artist2/Artist2 - Title2.mp3" ]]
}

@test "move_files_to_artist_folder - nominal twice with the same artist" {
    file1="${BATS_TEST_TMPDIR}/Artist1 - Title1.mp3"
    file2="${BATS_TEST_TMPDIR}/Artist1 - Title2.mp3"
    touch "$file1" "$file2"
    run move_files_to_artist_folder "${BATS_TEST_TMPDIR}"/*.mp3
    [[ "$status" -eq 0 ]]
    [[ ! -f "${BATS_TEST_TMPDIR}/Artist1 - Title1.mp3" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Artist1/Artist1 - Title1.mp3" ]]
    [[ ! -f "${BATS_TEST_TMPDIR}/Artist1 - Title2.mp3" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Artist1/Artist1 - Title2.mp3" ]]
}

@test "move_files_to_artist_folder - one invalid file" {
    file2="${BATS_TEST_TMPDIR}/InvalidFilename.mp3"
    file1="${BATS_TEST_TMPDIR}/Artist1 - Title1.mp3"
    touch "$file1" "$file2"
    run move_files_to_artist_folder "${BATS_TEST_TMPDIR}"/*.mp3
    [[ "$status" -eq 0 ]]
    [[ -f "${BATS_TEST_TMPDIR}/InvalidFilename.mp3" ]]
    [[ ! -f "${BATS_TEST_TMPDIR}/Artist1 - Title1.mp3" ]]
    [[ -f "${BATS_TEST_TMPDIR}/Artist1/Artist1 - Title1.mp3" ]]
    [[ "$output" == *"Failed to move"* ]]
}