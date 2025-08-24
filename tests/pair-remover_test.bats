#!/usr/bin/env bats

load '../pair-remover.sh'

## Setup functions

function setup_brackets() {
    # Declare a minimal set of brackets for testing
    declare -gA _BRACKETS=(
      ["("]=")"
      ["["]="]"
      ["{"]="}"
    )
}

## _remove_innermost_pair

@test "_remove_innermost_pair - nominal" {
    run _remove_innermost_pair "a(b(c)d)e" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "a(bd)e" ]
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

## _remove_pair

@test "_remove_pair - nominal" {
    run _remove_pair "a(b(c)d)e(f)g" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "aeg" ]
}

@test "_remove_pair - nominal nothing to remove" {
    run _remove_pair "abcde" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "abcde" ]
}

@test "_remove_pair - nominal unballanced left" {
    run _remove_pair "a(b(c)de" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "a(bde" ]
}

@test "_remove_pair - nominal unballanced right" {
    run _remove_pair "ab(c)d)e" "(" ")"
    [ "$status" -eq 0 ]
    [ "$output" = "abd)e" ]
}

## _remove_pairs

@test "_remove_pairs - nominal" {
    setup_brackets
    run _remove_pairs "a(b(c)d)e(f)g"
    [ "$status" -eq 0 ]
    [ "$output" = "aeg" ]
}

@test "_remove_pairs - nominal nothing to remove" {
    setup_brackets
    run _remove_pairs "abcde"
    [ "$status" -eq 0 ]
    [ "$output" = "abcde" ]
}

@test "_remove_pairs - nominal 2 bracket types" {
    setup_brackets
    run _remove_pairs "a(bc)[d]e"
    [ "$status" -eq 0 ]
    [ "$output" = "ae" ]
}
