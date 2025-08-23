#!/bin/bash

_escape_for_sed() {
  local char="$1"
  local specials=( '.' '^' '$' '*' '+' '?' '(' ')' '[' ']' '{' '}' '\' '|' '-' )
  
  for s in "${specials[@]}"; do
    if [[ "$char" == "$s" ]]; then
      printf '\\%s' "$char"
      return
    fi
  done

  # Not a special char, print as is
  printf '%s' "$char"
}

_remove_innermost_pair() {
  local str="$1"
  local left_esc right_esc

  left_esc=$(_escape_for_sed "$2")
  right_esc=$(_escape_for_sed "$3")

  echo "$str" | sed -E "s/${left_esc}[^${left_esc}${right_esc}]*${right_esc}//g"
}

remove_pair(){

  if [ $# -ne 3 ] ; then
    echo "invalid number of arguments...
    Example of usage: $0 \"my string(substring to remove)\" \"(\" \")\"">&2
    return 1
  fi

  local str="$1"
  local left_delim="$2"
  local right_delim="$3"

  local last_state="$str"
  local new_state=$(_remove_innermost_pair "$last_state" "$left_delim" "$right_delim")
  while [ "$last_state" != "$new_state" ] ; do
      last_state="$new_state"
      new_state=$(_remove_innermost_pair "$last_state" "$left_delim" "$right_delim")
  done

  echo "$new_state"
  return 0
}

# Clear sub functions
unset -f _escape_for_sed
unset -f _remove_innermost_pair