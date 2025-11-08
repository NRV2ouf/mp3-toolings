#!/usr/bin/env bats

load '../src/space-trimmer.sh'

## _trim_multi_spaces

@test "_trim_multi_spaces - nominal double spaces" {
    run _trim_multi_spaces '_  _'
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_ _" ]]
}

@test "_trim_multi_spaces - nominal double spaces twice" {
    run _trim_multi_spaces '_  _  _'
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_ _ _" ]]
}

@test "_trim_multi_spaces - nominal triple spaces" {
    run _trim_multi_spaces '_   _'
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_ _" ]]
}

@test "_trim_multi_spaces - no multiple spaces" {
    run _trim_multi_spaces '_ _ _'
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_ _ _" ]]
}

## _trim_leading_and_trailing_spaces

@test "_trim_leading_and_trailing_spaces - nominal leading space" {
    run _trim_leading_and_trailing_spaces ' _'
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_" ]]
}

@test "_trim_leading_and_trailing_spaces - nominal trailing space" {
    run _trim_leading_and_trailing_spaces '_ '
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_" ]]
}

@test "_trim_leading_and_trailing_spaces - nominal leading and trailing space" {
    run _trim_leading_and_trailing_spaces ' _ '
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_" ]]
}

@test "_trim_leading_and_trailing_spaces - nominal multiple leading and trailing spaces" {
    run _trim_leading_and_trailing_spaces '   _   '
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_" ]]
}

@test "_trim_leading_and_trailing_spaces - no leading or trailing spaces" {
    run _trim_leading_and_trailing_spaces '_'
    [[ "$status" -eq 0 ]]
    [[ "$output" = "_" ]]
}

## trim_spaces_from_filenames

@test "trim_spaces_from_filenames - nominal" {
    file="${BATS_TEST_TMPDIR}/file  name.txt"
    touch "$file"    
    run trim_spaces_from_filenames "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "${BATS_TEST_TMPDIR}/file name.txt" ]]
    [[ ! -f "$file" ]]
}

@test "trim_spaces_from_filenames - nominal leading and trailing spaces" {
    file="${BATS_TEST_TMPDIR}/  file name  .txt"
    touch "$file"    
    run trim_spaces_from_filenames "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "${BATS_TEST_TMPDIR}/file name.txt" ]]
    [[ ! -f "$file" ]]
}

@test "trim_spaces_from_filenames - nominal multiple spaces" {
    file="${BATS_TEST_TMPDIR}/file    name.txt"
    touch "$file"    
    run trim_spaces_from_filenames "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "${BATS_TEST_TMPDIR}/file name.txt" ]]
    [[ ! -f "$file" ]]
}

@test "trim_spaces_from_filenames - nominal no spaces to trim" {
    file="${BATS_TEST_TMPDIR}/filename.txt"
    touch "$file"    
    run trim_spaces_from_filenames "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "$file" ]]
}

@test "trim_spaces_from_filenames - nominal multiple files" {
    file1="${BATS_TEST_TMPDIR}/  file  name  .txt"
    file2="${BATS_TEST_TMPDIR}/another    file.txt"
    touch "$file1"    
    touch "$file2"
    run trim_spaces_from_filenames "$file1" "$file2"
    [[ "$status" -eq 0 ]]
    [[ -f "${BATS_TEST_TMPDIR}/file name.txt" ]]
    [[ ! -f "$file1" ]]
    [[ -f "${BATS_TEST_TMPDIR}/another file.txt" ]]
    [[ ! -f "$file2" ]]
}

@test "trim_spaces_from_filenames - nominal no files" {
    run trim_spaces_from_filenames
    [[ "$status" -eq 0 ]]
}

@test "trim_spaces_from_filenames - nominal idempotence" {
    file="${BATS_TEST_TMPDIR}/  file  name  .txt"
    touch "$file"    
    run trim_spaces_from_filenames "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "${BATS_TEST_TMPDIR}/file name.txt" ]]
    [[ ! -f "$file" ]]

    file="${BATS_TEST_TMPDIR}/file name.txt"
    run trim_spaces_from_filenames "$file"
    [[ "$status" -eq 0 ]]
    [[ -f "$file" ]]
}