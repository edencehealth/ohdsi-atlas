#!/bin/sh
# this script creates an optimally-compressed copy of each file given in the
# argument list; these compressed files are served by nginx if they exist; see
# the nginx gzip_static setting for more information
set -eu;
SELF=$(basename "$0" '.sh')
DEBUG="${DEBUG:-}"  # set to a non-empty value to enable debug output

log() {
  printf '%s %s %s\n' "$(date '+%FT%T%z')" "$SELF" "$*" >&2
}

die() {
  log "FATAL:" "$@"
  exit 1
}

max_gzip() {
  input_file="${1:?an input file argument is required}"
  output_file="${input_file}.gz"
  tmp_dir=$(mktemp -d '/tmp/maxcompress.XXXXXX') || exit 1

  for level in 1 2 3 4 5 6 7 8 9; do
    archive="${tmp_dir}/${level}.gz"
    gzip "-${level}" -c "${input_file}" >"${archive}" &
  done

  wait || exit 2

  smallest_file=$(stat -c '%s %n' "${tmp_dir}/"*".gz" | sort -n | head -n 1 | awk '{print $2}')
  cat "$smallest_file" >"$output_file"
  [ -n "$DEBUG" ] && log "${output_file}: using ${smallest_file}"
  rm -r "${tmp_dir}"

  input_file_owners=$(stat -c '%u:%g' "${input_file}")
  input_file_mode=$(stat -c '%a' "${input_file}")

  chown "$input_file_owners" "$output_file"
  chmod "$input_file_mode" "$output_file"
  touch -r "$input_file" "$output_file"
}

main() {
  # sanity check
  if uname | grep -Eiq "(bsd|darwin)"; then
    die "use of 'stat -c' in this script isn't portable from linux"
  fi

  # loop over file path arguments
  for target_file in "$@"; do
    max_gzip "$target_file"

    # did we actually achieve compression? if not, delete the gzip file
    archive_file="${target_file}.gz"
    archive_size=$(stat -c '%s' "$archive_file")
    target_file_size=$(stat -c '%s' "$target_file")
    if [ "$archive_size" -ge "$target_file_size" ]; then
      [ -n "$DEBUG" ] && log "${target_file}: SKIPPED - " \
        "all compression attempts resulted in a larger filesize"
      rm "$archive_file"
    fi
  done
}

main "$@"; exit
