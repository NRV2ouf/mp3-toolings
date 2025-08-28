#!/bin/bash

# @name PairRemover
# @brief A set of function meant to remove paired delimiters (brackets, parentheses, etc.) and their contents from filenames.
# @description This script defines a function `remove_brackets_from_filenames`
#  that takes one or more file or directory paths as arguments. It scans each
#  filename for known paired delimiters (like (), [], {}, etc.) and removes
#  these delimiters along with any text enclosed within.
#  
#  Bash 4+ is required for associative arrays.

if [[ -z ${BASH_VERSINFO+x} || ${BASH_VERSINFO[0]} -lt 4 ]]; then
  echo "brackets.sh: needs Bash 4+ (associative arrays)" >&2
  return 1 2>/dev/null || exit 1
fi

# Tip: ensure UTF-8 locale so Unicode characters behave
export LC_ALL=${LC_ALL:-C.UTF-8}

# @name _BRACKETS
# @description An associative array mapping opening brackets to their corresponding closing brackets.
# @details This array includes a variety of bracket types, including ASCII brackets,
#   mathematical brackets, CJK corner brackets, angle/guillemet styles, fullwidth forms,
#   and small forms (compatibility).
# @example
#   echo "${_BRACKETS["("]}"  # Outputs: )
#   echo "${_BRACKETS["「"]}"  # Outputs: 」
declare -A _BRACKETS=(
  # ASCII
  ["("]=")"
  ["["]="]"
  ["{"]="}"
  ["<"]=">"

  # Math / technical
  ["⟨"]="⟩"   # mathematical angle bracket
  ["⟪"]="⟫"   # double angle bracket
  ["⟦"]="⟧"   # white square bracket
  ["⌈"]="⌉"   # ceiling
  ["⌊"]="⌋"   # floor
  ["⟮"]="⟯"   # tall parentheses
  ["⟬"]="⟭"   # white tortoise shell bracket
  ["⦇"]="⦈"   # Z notation image bracket
  ["⦉"]="⦊"   # Z notation binding bracket

  # CJK corner & lenticular
  ["「"]="」"
  ["『"]="』"
  ["【"]="】"
  ["〔"]="〕"
  ["〖"]="〗"
  ["〘"]="〙"
  ["〚"]="〛"

  # Angle/guillemet styles
  ["〈"]="〉"
  ["《"]="》"
  ["«"]="»"
  ["‹"]="›"

  # Fullwidth forms
  ["（"]="）"
  ["［"]="］"
  ["｛"]="｝"
  ["｟"]="｠"   # fullwidth white parenthesis

  # Small forms (compatibility)
  ["﹙"]="﹚"
  ["﹛"]="﹜"
  ["﹝"]="﹞"
)

# @name _escape_for_sed
# @description Escapes special characters for use in sed patterns.
# @arg $1 String The character to escape.
# @stdout The escaped character if it is special, otherwise the character itself.
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

# @name _remove_innermost_pair
# @description Removes the innermost occurrences of the specified left and
#   right delimiters from the input string.
# @arg $1 String The input string to process.
# @arg $2 String The left delimiter character.
# @arg $3 String The right delimiter character.
# @stdout The processed string with the innermost specified bracket pairs removed.
# @example
#   _remove_innermost_pair "example (test (nested)) demo" "(" ")"
#   -> "example (nested) demo"
_remove_innermost_pair() {
  local str="$1"
  local left="$2"
  local right="$3"
  left_esc=$(_escape_for_sed "$left")
  right_esc=$(_escape_for_sed "$right")

  echo "$str" | sed -E "s/${left_esc}[^${right}${left}]*${right_esc}//g"
}

# @name _remove_pair
# @description Removes all occurrences of the pairs of the specified left and 
#   right delimiters from the input string. It repeatedly applies the removal
#   until no more pairs can be found.
# @arg $1 String The input string to process.
# @arg $2 String The left delimiter character.
# @arg $3 String The right delimiter character.
# @stdout The processed string with all specified bracket pairs removed.
# @example
#   _remove_pair "example (test (nested)) demo" "(" ")"
#   -> "example  demo"
_remove_pair(){
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
}

# @name _remove_pairs
# @description Removes all pairs of brackets defined in the associative array 
#   `_BRACKETS` from the input string.
# @arg $1 String The input string to process.
# @stdout The processed string with all bracket pairs removed.
# @example
#   _remove_pairs "example (test) [demo] {sample}"
#   -> "example   "
_remove_pairs(){
  local parsed_str="$1"  
  for l in "${!_BRACKETS[@]}"; do
    r="${_BRACKETS[$l]}"
    parsed_str="$(_remove_pair "$parsed_str" "$l" "$r")"
  done
  echo "$parsed_str"
}

# @name remove_brackets_from_filenames
# @description For each provided path, the function looks up a list of known 
#   bracket types (defined in the associative array `_BRACKETS`) and removes
#   all occurrences of these brackets and any text enclosed within them from.
# @arg $@ Files One or more paths to scan. Each argument should be a directory or file.
# @example
#   remove_brackets_from_filenames file1.mp3 "dir/file2 (live).mp3"
remove_brackets_from_filenames() {
  for file in "$@"; do
    local dir=$(dirname -- "$file")
    local base=$(basename -- "$file")
    local ext=".${base##*.}"
    if [ "$ext" == ".$base" ]; then
      ext=""
    fi
    local name="${base%.*}" # File name without extension
    local new_name=$(_remove_pairs "$name")
    local new_base="${new_name}${ext}"
    if [ "${base}" == "${new_base}" ]; then
      continue
    fi
    mv -- "$file" "$dir/$new_base"
  done
}