#!/usr/bin/env bash

set -ex

file_arch_cc="$1"

typedef_strings=$(grep '^typedef' "$file_arch_cc")
typedef_strings="${typedef_strings//$'\n'/\\n}"

err_t_strings=$(grep 'LWIP_ERR_T' "$file_arch_cc")

file_in="$2"
file_out="$3"

sed \
    -e 's!@GLUE_LWIP_TYPEDEF_STRINGS@!'"$typedef_strings"'!' \
    -e 's!@GLUE_LWIP_ERR_T_DEFINITION@!'"$err_t_strings"'!' \
    "$file_in" > "$file_out"
