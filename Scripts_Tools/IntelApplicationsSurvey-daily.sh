#!/usr/bin/env zsh
set -euo pipefail

# Script for Jamf
# Store the generated property list in the preferences directory.
output_directory="/Library/Preferences"
output_file="$output_directory/ch.ethz.jamf.intel-apps.plist"

# Build the file separately so an interrupted run cannot leave partial XML behind.
temporary_file="$(mktemp "$output_file.XXXXXX")" || exit 1
trap 'rm -f "$temporary_file"' EXIT


system_profiler SPApplicationsDataType 2>/dev/null | awk '
function trim(value) {
  sub(/^[[:space:]]+/, "", value)
  sub(/[[:space:]]+$/, "", value)
  return value
}

function xml_escape(value) {
  gsub(/[[:cntrl:]]/, "", value)
  gsub(/&/, "\\&amp;", value)
  gsub(/</, "\\&lt;", value)
  gsub(/>/, "\\&gt;", value)
  gsub(/\"/, "\\&quot;", value)
  return value
}

function store_app() {
  if (is_intel && app != "" && loc != "") {
    entries = entries "    <dict>\n"
    entries = entries "      <key>Name</key>\n"
    entries = entries "      <string>" xml_escape(app) "</string>\n"
    entries = entries "      <key>Location</key>\n"
    entries = entries "      <string>" xml_escape(loc) "</string>\n"
    entries = entries "    </dict>\n"
    found = 1
  }
  app = ""
  loc = ""
  is_intel = 0
}

BEGIN {
  found = 0
  entries = ""
  print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  print "<\!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
  print "<plist version=\"1.0\">"
  print "  <dict>"
  print "    <key>IntelApps</key>"
}

/^[[:space:]]{4}[^[:space:]].*:[[:space:]]*$/ {
  store_app()
  app = trim($0)
  sub(/:$/, "", app)
  next
}

/Kind:[[:space:]]*Intel/ {
  is_intel = 1
  next
}

/^[[:space:]]*Location:[[:space:]]*/ {
  loc = $0
  sub(/^[[:space:]]*Location:[[:space:]]*/, "", loc)
  loc = trim(loc)
  next
}

END {
  store_app()
  if (!found) {
    print "    <string>No Intel Apps installed</string>"
  } else {
    print "    <array>"
    printf "%s", entries
    print "    </array>"
  }
  print "  </dict>"
  print "</plist>"
}
' > "$temporary_file"

if ! /usr/bin/plutil -lint "$temporary_file" >/dev/null 2>&1; then
  print -u2 "Generated plist failed validation."
  exit 1
fi

if [[ -e "$output_file" ]] && cmp -s "$temporary_file" "$output_file"; then
  rm -f "$temporary_file"
  exit 0
fi

mv -f "$temporary_file" "$output_file"
if [[ "$(stat -f '%Lp' "$output_file")" != "644" ]]; then
  chmod 644 "$output_file"
fi
