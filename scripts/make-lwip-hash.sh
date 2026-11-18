#!/usr/bin/env bash

set -e

lwip_dir="$1"
file_in="$2"
file_out="$3"

lwip_desc=$(git -C "$lwip_dir" describe --tag)
glue_desc=$(git describe --tag --always)

sed \
    -e 's!@LWIP_REPO_DESC_STR@!'"$lwip_desc"'!' \
    -e 's!@GLUE_REPO_DESC_STR@!'"$glue_desc"'!' \
    "$file_in" > "$file_out"
