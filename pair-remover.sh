#!/bin/bash

# Require Bash 4+ for associative arrays
if [[ -z ${BASH_VERSINFO+x} || ${BASH_VERSINFO[0]} -lt 4 ]]; then
  echo "brackets.sh: needs Bash 4+ (associative arrays)" >&2
  return 1 2>/dev/null || exit 1
fi

# Tip: ensure UTF-8 locale so Unicode characters behave
export LC_ALL=${LC_ALL:-C.UTF-8}

# Opening → Closing
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
  local left="$2"
  local right="$3"
  left_esc=$(_escape_for_sed "$left")
  right_esc=$(_escape_for_sed "$right")

  echo "$str" | sed -E "s/${left_esc}[^${right}${left}]*${right_esc}//g"
}

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

_remove_pairs(){
  local parsed_str="$1"  
  for l in "${!_BRACKETS[@]}"; do
    r="${_BRACKETS[$l]}"
    parsed_str="$(_remove_pair "$parsed_str" "$l" "$r")"
  done
  echo "$parsed_str"
}

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