#!/usr/bin/env bats

load '../utils.sh'

## _count_good_dashes

@test "_count_good_dashes - nominal" {
    run _count_good_dashes " - "
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
}

@test "_count_good_dashes - empty" {
    run _count_good_dashes ""
    [ "$status" -eq 0 ]
    [ "$output" = "0" ]
}

@test "_count_good_dashes - no dashes" {
    run _count_good_dashes "abc"
    [ "$status" -eq 0 ]
    [ "$output" = "0" ]
}

@test "_count_good_dashes - no good dashes" {
    run _count_good_dashes "a-b"
    [ "$status" -eq 0 ]
    [ "$output" = "0" ]
}

@test "_count_good_dashes - mixed characters" {
    run _count_good_dashes "-a - b - c---"
    [ "$status" -eq 0 ]
    [ "$output" = "2" ]
}

## _get_title

@test "_get_title - nominal" {
    run _get_title "artist - title"
    [ "$status" -eq 0 ]
    [ "$output" = "title" ]
}

@test "_get_title - no dash" {
    run _get_title "artist title"
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
}

@test "_get_title - multiple dashes" {
    run _get_title "artist - title - remix"
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
}

@test "_get_title - empty string" {
    run _get_title ""
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
}

## _get_artist

@test "_get_artist - nominal" {
    run _get_artist "artist - title"
    [ "$status" -eq 0 ]
    [ "$output" = "artist" ]
}

@test "_get_artist - no dash" {
    run _get_artist "artist title"
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
}

@test "_get_artist - multiple dashes" {
    run _get_artist "artist - title - remix"
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
}

@test "_get_artist - empty string" {
    run _get_artist ""
    [ "$status" -ne 0 ]
    [ "$output" = "" ]
}