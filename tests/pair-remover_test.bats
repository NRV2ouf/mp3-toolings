#!/usr/bin/env bats

load '../pair-remover.sh'

setup() {
    declare -gA _BRACKETS=(
      ["("]=")"
      ["["]="]"
      ["{"]="}"
    )
}

teardown() {
    unset _BRACKETS
}

## _remove_innermost_pair

@test "_remove_innermost_pair - nominal" {
    run _remove_innermost_pair "a(b(c)d)e" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "a(bd)e" ]
}

@test "_remove_innermost_pair - nominal [ ]" {
    run _remove_innermost_pair "a[b[c]d]e" "[" "]"
    [ "$status" -eq 0 ]
    [ "$output" = "a[bd]e" ]
}

@test "_remove_innermost_pair - nominal nothing to remove" {
    run _remove_innermost_pair "abcde" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "abcde" ]
}

@test "_remove_innermost_pair - nominal 2 removals" {
    run _remove_innermost_pair "a(b(c)d)(e)" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "a(bd)" ]
}

@test "_remove_innermost_pair - nominal unbalanced left" {
    run _remove_innermost_pair "a(bcde" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "a(bcde" ]
}

@test "_remove_innermost_pair - nominal unbalanced right" {
    run _remove_innermost_pair "abcd)e" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "abcd)e" ]
}

@test "_remove_innermost_pair - nominal unballanced left [ ]" {
    run _remove_innermost_pair "a[b[c]de" "[" "]"
    [ "$status" -eq 0 ]
    [ "$output" = "a[bde" ]
}

@test "_remove_innermost_pair - nominal unballanced right [ ]" {
    run _remove_innermost_pair "ab[c]d]e" "[" "]"
    [ "$status" -eq 0 ]
    [ "$output" = "abd]e" ]
}

## _remove_pair

@test "_remove_pair - nominal" {
    run _remove_pair "a(b(c)d)e(f)g" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "aeg" ]
}

@test "_remove_pair - nominal real case" {
    run _remove_pair "artist (ft. enculos) - title [audio version].mp3" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "artist  - title [audio version].mp3" ]
}

@test "_remove_pair - nominal nothing to remove" {
    run _remove_pair "abcde" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "abcde" ]
}

## _remove_pairs

@test "_remove_pairs - nominal" {
    run _remove_pairs "a(b(c)d)e(f)g"
    [ "$status" -eq 0 ]
    [ "$output" = "aeg" ]
}

@test "_remove_pairs - nominal real case" {
    run _remove_pairs "artist (ft. enculos) - title [audio version].mp3"
    [ "$status" -eq 0 ]
    [ "$output" = "artist  - title .mp3" ]
}

@test "_remove_pairs - nominal nothing to remove" {
    run _remove_pairs "abcde"
    [ "$status" -eq 0 ]
    [ "$output" = "abcde" ]
}

@test "_remove_pairs - nominal 2 bracket types" {
    run _remove_pairs "a(bc)[d]e"
    [ "$status" -eq 0 ]
    [ "$output" = "ae" ]
}

# remove_brackets_from_filenames

@test "remove_brackets_from_filenames - nominal" {
    file="${BATS_TMPDIR}/ab(c)de"
    touch "$file"

    run remove_brackets_from_filenames "$file"
    [ "$status" -eq 0 ]
    [ -f "$BATS_TMPDIR/abde" ]
    [ ! -f "$file" ]
}

@test "remove_brackets_from_filenames - nominal with extension" {
    file="${BATS_TMPDIR}/ab(c)de.ext"
    touch "$file"

    run remove_brackets_from_filenames "$file"
    [ "$status" -eq 0 ]
    [ -f "$BATS_TMPDIR/abde" ]
    [ ! -f "$file" ]
}

@test "remove_brackets_from_filenames - nominal 2 removals" {
    file="${BATS_TMPDIR}/ab(c)d[e]"
    touch "$file"

    run remove_brackets_from_filenames "$file"
    [ "$status" -eq 0 ]
    [ -f "$BATS_TMPDIR/abd" ]
    [ ! -f "$file" ]
}

@test "remove_brackets_from_filenames - nominal nothing to remove" {
    file="${BATS_TMPDIR}/abcde"
    touch "$file"

    run remove_brackets_from_filenames "$file"
    [ "$status" -eq 0 ]
    [ -f "$file" ]
}

@test "remove_brackets_from_filenames - nominal real case" {
    file="${BATS_TMPDIR}/artist (ft. enculos) - title [audio version].mp3"
    touch "$file"

    run remove_brackets_from_filenames "$file"
    [ "$status" -eq 0 ]
    [ -f "$BATS_TMPDIR/artist  - title .mp3" ]
    [ ! -f "$file" ]
}

@test "remove_brackets_from_filenames - nominal 2 files" {
    file1="${BATS_TMPDIR}/ab(c)d[e]"
    file2="${BATS_TMPDIR}/xyz{123}foo"
    touch "$file1" "$file2"

    run remove_brackets_from_filenames "$file1" "$file2"
    [ "$status" -eq 0 ]
    [ -f "$BATS_TMPDIR/abd" ]
    [ ! -f "$file1" ]
    [ -f "$BATS_TMPDIR/xyzfoo" ]
    [ ! -f "$file2" ]
}

@test "remove_brackets_from_filenames - nominal idempotence" {
    file="${BATS_TMPDIR}/ab(c)d[e]"
    touch "$file"

    run remove_brackets_from_filenames "$file"
    [ "$status" -eq 0 ]
    [ -f "$BATS_TMPDIR/abd" ]
    [ ! -f "$file" ]

    run remove_brackets_from_filenames "$BATS_TMPDIR/abd"
    [ "$status" -eq 0 ]
    [ -f "$BATS_TMPDIR/abd" ]
}