#!/bin/bash

COMMAND_NAME=fd
HELP=$(fd --help)

function get-long-options {
  X="$(echo "$1" | sed -n -e '
    # no short style
    /^ \{8\}--[a-zA-Z]/ {
      h
      s/^ \+--\([a-zA-Z\-]\+\).*/\1/
      p

      g
      s/^ \+--[a-zA-Z\-]\+ *\([^ ]*\).*/\1/
      p

      n
      s/^ \+//
      s/^-.*//
      p

      c END
      p
    }
  ')"
  readarray -t PAIRS <<<"$X"
  for ((i=0;i<${#PAIRS[@]};i+=4)); do
    echo -n "complete -c" "$COMMAND_NAME" "-l" "${PAIRS[i]}"
    long="${PAIRS[i]}"
    trail="${PAIRS[i+1]}"
    desc="${PAIRS[i+2]}"
    if test "$desc" != ""; then
      echo -n " -d" "\"${desc}; ${long}\""
    else
      echo -n " -d" "\"${long}\""
    fi
    if test "$trail" == "<path>"; then
      echo -n " -r -F"
    else
      echo -n " -r -f"
    fi
    echo
  done
}

function get-long-options-with-short {
  X="$(echo "$1" | sed -n -e '
    # with short style
    /^ \+-[a-zA-Z], --[a-zA-Z]/ {
      h
      s/^ \+-[a-zA-Z], --\([a-zA-Z\-]\+\).*/\1/
      p

      g
      s/^ \+-\([a-zA-Z]\), --[a-zA-Z\-].*/\1/
      p

      g
      s/^ \+-[a-zA-Z], --[a-zA-Z\-].* *\([^ ]*\).*/\1/
      p

      n
      s/^ \+//
      s/^-.*//
      p

      c END
      p
    }
  ')"
  readarray -t PAIRS <<<"$X"
  for ((i=0;i<${#PAIRS[@]};i+=5)); do
    long="${PAIRS[i]}"
    short="${PAIRS[i+1]}"
    trail="${PAIRS[i+2]}"
    desc="${PAIRS[i+3]}"
    echo -n "complete -c" "$COMMAND_NAME" "-l" "$long" -s "$short"
    if test "$desc" != ""; then
      echo -n " -d" "\"${desc}; ${long}\""
    else
      echo -n " -d" "\"${long}\""
    fi
    if test "$trail" == "<path>"; then
      echo -n " -r -F"
    else
      echo -n " -r -f"
    fi
    echo
  done
}

echo "complete -f -c fd"
get-long-options "$HELP"
get-long-options-with-short "$HELP"
