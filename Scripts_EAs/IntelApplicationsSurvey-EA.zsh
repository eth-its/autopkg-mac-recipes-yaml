#!/bin/zsh 
# EA for Jamf
# Store the generated property list in the preferences directory.
output_file="/Library/Preferences/ch.ethz.jamf.intel-apps.plist"

# Return a valid Jamf result when the plist is unavailable or invalid.
if [[ ! -r "$output_file" ]] || ! /usr/bin/plutil -lint "$output_file" >/dev/null 2>&1; then
	print '<result>No Intel apps found. (Invalid plist)</result>'
	exit 0
fi

plist_value="$(/usr/libexec/PlistBuddy -c 'Print :IntelApps' "$output_file" 2>/dev/null || true)"

if [[ "$plist_value" == "No Intel Apps installed" ]]; then
	print '<result>No Intel apps found.</result>'
	exit 0
fi

if [[ -z "$plist_value" ]]; then
	print '<result>No Intel apps found. (Empty plist)</result>'
	exit 0
fi

result="$(print -r -- "$plist_value" | awk '
function xml_escape(value) {
	gsub(/[[:cntrl:]]/, "", value)
	gsub(/&/, "\\&amp;", value)
	gsub(/</, "\\&lt;", value)
	gsub(/>/, "\\&gt;", value)
	return value
}

/^[[:space:]]*Name = / {
	name = $0
	sub(/^[[:space:]]*Name = /, "", name)
}

/^[[:space:]]*Location = / {
	location = $0
	sub(/^[[:space:]]*Location = /, "", location)
	if (name != "") {
		print xml_escape(name) ";" xml_escape(location)
		name = ""
	}
}
' )"

if [[ -n "$result" ]]; then
	print -r -- "<result>$result</result>"
else
	print '<result>No Intel apps found. (No valid app entries)</result>'
fi