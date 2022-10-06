#!/bin/bash

get_marketing_model_name() {
	##
	## Created by Pico Mitchell (of Free Geek)
	##
	## Version: 2022.10.5-1
	##
	## MIT License
	##
	## Copyright (c) 2021 Free Geek
	##
	## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
	## to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
	## and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	##
	## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	##
	## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	##

	local PATH='/usr/bin:/bin:/usr/sbin:/sbin:/usr/libexec' # Add /usr/libexec to PATH for easy access to PlistBuddy.

	# THE NEXT 3 VARIABLES CAN OPTIONALLY BE SET TO "true" TO ALTER THE OUTPUT:
	local -r DEBUG_LOGGING=false # Set to "true" for logging to stderr to see how the Marketing Model Name is being loaded and if and where it is being cached as well as other debug info.
	local -r ALWAYS_INCLUDE_MODEL_ID=false # Set to "true" if you want to always include the Model ID in the output after the Marketing Model Name (it will be included in the output from this script but it won't be cached to not alter the "About This Mac" model name).
	local -r INCLUDE_MODEL_PART_NUMBER=false # Set to "true" if you want to include the "M####LL/A" style Model Part Number in the output after the Marketing Model Name for T2 and Apple Silicon Macs (it will be included in the output from this script but it won't be cached to not alter the "About This Mac" model name).

	local MODEL_IDENTIFIER
	MODEL_IDENTIFIER="$(sysctl -n hw.model 2> /dev/null)"
	if [[ -z "${MODEL_IDENTIFIER}" ]]; then MODEL_IDENTIFIER='UNKNOWN Model Identifier'; fi # This should never happen, but will result in some useful feedback if somehow "sysctl" fails to return a Model Identifier.
	readonly MODEL_IDENTIFIER
	if $DEBUG_LOGGING; then >&2 echo "DEBUG - MODEL ID: ${MODEL_IDENTIFIER}"; fi

	local IS_APPLE_SILICON
	IS_APPLE_SILICON="$([[ "$(sysctl -in hw.optional.arm64)" == '1' ]] && echo 'true' || echo 'false')"
	readonly IS_APPLE_SILICON

	local MAC_IS_VIRTUAL_MACHINE
	# "machdep.cpu.features" is always EMPTY on Apple Silicon (whether or not it's a VM) so it cannot be used to check for the "VMM" feature flag when the system is a VM,
	# but I examined the full "sysctl -a" output when running a VM on Apple Silicon and found that "kern.hv_vmm_present" is set to "1" when running a VM and "0" when not.
	# Though testing, I found the "kern.hv_vmm_present" key is also the present on Intel Macs starting with macOS version macOS 11 Big Sur and gets properly set to "1"
	# on Intel VMs, but still check for either since "kern.hv_vmm_present" is not available on every version of macOS that this script may be run on.
	MAC_IS_VIRTUAL_MACHINE="$([[ " $(sysctl -in machdep.cpu.features) " == *' VMM '* || "$(sysctl -in kern.hv_vmm_present)" == '1' ]] && echo 'true' || echo 'false')"
	readonly MAC_IS_VIRTUAL_MACHINE
	if $DEBUG_LOGGING; then >&2 echo "DEBUG - IS VM: ${MAC_IS_VIRTUAL_MACHINE}"; fi

	local possible_marketing_model_name
	local marketing_model_name

	if $IS_APPLE_SILICON; then
		# This local Marketing Model Name within "ioreg" only exists on Apple Silicon Macs.
		if $DEBUG_LOGGING; then >&2 echo 'DEBUG - LOADING FROM IOREG ON APPLE SILICON'; fi
		possible_marketing_model_name="$(PlistBuddy -c 'Print :0:product-name' /dev/stdin <<< "$(ioreg -arc IOPlatformDevice -k product-name)" 2> /dev/null | tr -dc '[:print:]')" # Remove non-printable characters because this decoded value could end with a null char.

		if $MAC_IS_VIRTUAL_MACHINE; then
			# It appears that Apple Silicon Virtual Machines will always output "Apple Virtual Machine 1" as their local Marketing Model Name from the previous "ioreg" command.
			# I'm not sure if that trailing "1" could ever be another number and whether it indicates some version or what.
			# But, if the retrieved local Marketing Model Name contains "Virtual Machine", we will only output "Apple Silicon Virtual Machine" instead to be more specific instead.
			# If this ever changes in the future and the local Marketing Model Name DOES NOT contain "Virtual Machine", then the retrieved local Marketing Model Name will
			# ALSO be displayed like "Apple Silicon Virtual Machine: [LOCAL MARKETING MODEL NAME]" to give the most possible info, like is done for Intel Virtual Machines.

			marketing_model_name='Apple Silicon Virtual Machine'

			if [[ "${possible_marketing_model_name}" != *'Virtual Machine'* ]]; then
				marketing_model_name+=": ${possible_marketing_model_name}"
			fi
		else
			marketing_model_name="${possible_marketing_model_name}"
		fi
	else
		local SERIAL_NUMBER
		SERIAL_NUMBER="$(PlistBuddy -c 'Print :0:IOPlatformSerialNumber' /dev/stdin <<< "$(ioreg -arc IOPlatformExpertDevice -k IOPlatformSerialNumber -d 1)" 2> /dev/null)"
		readonly SERIAL_NUMBER
		if $DEBUG_LOGGING; then >&2 echo "DEBUG - SERIAL: ${SERIAL_NUMBER}"; fi

		local load_fallback_marketing_model_name=false

		if (( ${#SERIAL_NUMBER} >= 11 )); then
			# The model part of the Serial Number is the last 4 characters for 12 character serials and the last 3 characters for 11 character serials (which are very old and shouldn't actually be encountered: https://www.macrumors.com/2010/04/16/apple-tweaks-serial-number-format-with-new-macbook-pro/).
			# Starting with the 2021 MacBook Pro models, randomized 10 character Serial Numbers are now used which do not have any model specific characters, but those Macs will never get here or need to load the Marketing Model Name over the internet since they are Apple Silicon and the local Marketing Model Name will have been retrieved above.
			local model_characters_of_serial_number="${SERIAL_NUMBER:8}"
			local marketing_model_name_was_cached=false

			if [[ "${EUID:-$(id -u)}" == '0' ]]; then # If running as root, check for the cached Marketing Model Name from the current user and if not found check for it from any and all other users.
				local current_user_id
				current_user_id="$(echo 'show State:/Users/ConsoleUser' | scutil | awk '($1 == "UID") { print $NF; exit }')"
				local current_user_name
				if [[ -n "${current_user_id}" ]] && (( current_user_id != 0 )); then
					current_user_name="$(dscl /Search -search /Users UniqueID "${current_user_id}" 2> /dev/null | awk '{ print $1; exit }')"
				fi

				if [[ -n "${current_user_name}" ]]; then # Always check cached preferences for current user first so that we know whether or not it needs to be cached for the current user if it is already cached for another user.
					if $DEBUG_LOGGING; then >&2 echo "DEBUG - CHECKING CURRENT USER ${current_user_name} DEFAULTS"; fi
					# Since "defaults read" has no option to traverse into keys of dictionary values, use the whole "defaults export" output and parse it with "PlistBuddy" to get at the specific key of the "CPU Names" dictionary value that we want.
					# Using "defaults export" instead of accessing the plist file directly with "PlistBuddy" is important since preferences are not guaranteed to be written to disk if they were just set.
					possible_marketing_model_name="$(PlistBuddy -c "Print :'CPU Names':${model_characters_of_serial_number}-en-US_US" /dev/stdin <<< "$(launchctl asuser "${current_user_id}" sudo -u "${current_user_name}" defaults export com.apple.SystemProfiler -)" 2> /dev/null)"

					if [[ "${possible_marketing_model_name}" == *'Mac'* ]]; then
						if $DEBUG_LOGGING; then >&2 echo "DEBUG - LOADED FROM CURRENT USER ${current_user_name} CACHE"; fi
						marketing_model_name="${possible_marketing_model_name}"
						marketing_model_name_was_cached=true
					fi
				fi

				if [[ -z "${marketing_model_name}" ]]; then # If was not cached for current user, check any and all other users.
					local this_home_folder
					local user_name_for_home
					local user_id_for_home
					for this_home_folder in '/Users/'*; do
						if [[ -d "${this_home_folder}" && "${this_home_folder}" != '/Users/Shared' && "${this_home_folder}" != '/Users/Guest' ]]; then
							user_name_for_home="$(dscl /Search -search /Users NFSHomeDirectory "${this_home_folder}" | awk '{ print $1; exit }')"

							if [[ -n "${user_name_for_home}" ]]; then
								user_id_for_home="$(dscl -plist /Search -read "/Users/${user_name_for_home}" UniqueID 2> /dev/null | xmllint --xpath '//string[1]/text()' - 2> /dev/null)"

								if [[ -n "${user_id_for_home}" && "${user_id_for_home}" != '0' && ( -z "${current_user_name}" || "${current_user_name}" != "${user_name_for_home}" ) ]]; then # No need to check current user in this loop since it was already checked.
									if $DEBUG_LOGGING; then >&2 echo "DEBUG - CHECKING ${this_home_folder} DEFAULTS"; fi
									possible_marketing_model_name="$(PlistBuddy -c "Print :'CPU Names':${model_characters_of_serial_number}-en-US_US" /dev/stdin <<< "$(launchctl asuser "${user_id_for_home}" sudo -u "${user_name_for_home}" defaults export com.apple.SystemProfiler -)" 2> /dev/null)" # See notes above about using "PlistBuddy" with "defaults export".

									if [[ "${possible_marketing_model_name}" == *'Mac'* ]]; then
										if $DEBUG_LOGGING; then >&2 echo "DEBUG - LOADED FROM ${this_home_folder} CACHE"; fi
										marketing_model_name="${possible_marketing_model_name}"

										if [[ -z "${current_user_name}" ]]; then # DO NOT consider the Marketing Model Name cached if there is a current user that it was not cached for so that it can be cached to the current user.
											marketing_model_name_was_cached=true
										elif $DEBUG_LOGGING; then
											>&2 echo 'DEBUG - NOT CONSIDERING IT CACHED SINCE THERE IS A CURRENT USER'
										fi

										break
									fi
								elif $DEBUG_LOGGING; then
									>&2 echo "DEBUG - SKIPPING ${this_home_folder} SINCE IS CURRENT USER"
								fi
							fi
						fi
					done
				fi
			else # If running as a user, won't be able to check others home folders, so only check current user preferences.
				if $DEBUG_LOGGING; then >&2 echo 'DEBUG - CHECKING CURRENT USER DEFAULTS'; fi
				possible_marketing_model_name="$(PlistBuddy -c "Print :'CPU Names':${model_characters_of_serial_number}-en-US_US" /dev/stdin <<< "$(defaults export com.apple.SystemProfiler -)" 2> /dev/null)" # See notes above about using "PlistBuddy" with "defaults export".

				if [[ "${possible_marketing_model_name}" == *'Mac'* ]]; then
					if $DEBUG_LOGGING; then >&2 echo 'DEBUG - LOADED FROM CURRENT USER CACHE'; fi
					marketing_model_name="${possible_marketing_model_name}"
					marketing_model_name_was_cached=true
				fi
			fi

			if [[ -z "${marketing_model_name}" ]]; then
				local marketing_model_name_xml
				marketing_model_name_xml="$(curl -m 5 -sL "https://support-sp.apple.com/sp/product?cc=${model_characters_of_serial_number}" 2> /dev/null)"

				if [[ "${marketing_model_name_xml}" == '<?xml'* ]]; then
					possible_marketing_model_name="$(echo "${marketing_model_name_xml}" | xmllint --xpath '//configCode/text()' - 2> /dev/null)"

					if [[ "${possible_marketing_model_name}" == *'Mac'* ]]; then
						if $DEBUG_LOGGING; then >&2 echo 'DEBUG - LOADED FROM "About This Mac" URL API'; fi
						marketing_model_name="${possible_marketing_model_name}"
					else
						if $DEBUG_LOGGING; then >&2 echo "DEBUG - INVALID FROM \"About This Mac\" URL API (${possible_marketing_model_name:-N/A}): ${marketing_model_name_xml}"; fi

						marketing_model_name="${MODEL_IDENTIFIER} (Invalid Serial Number for Marketing Model Name)"
						load_fallback_marketing_model_name=true
					fi
				elif $DEBUG_LOGGING; then
					>&2 echo 'DEBUG - FAILED TO LOAD FROM "About This Mac" URL API'
				fi
			fi

			if $load_fallback_marketing_model_name || [[ -z "${marketing_model_name}" ]]; then
				# The following URL API and JSON structure was discovered from examining how "https://support.apple.com/specs/${SERIAL_NUMBER}" loads the specs URL via JavaScript (as of August 9th, 2022 in case this breaks in the future).
				# This alternate technique of getting the Marketing Model Name for a Serial Number from this URL API should not be necessary as the previous one should have always worked for valid serials,
				# but including it here anyway just in case the older URL API stops working at some point and also as a reference for how this "Specs Search" URL method can be used.
				# Also worth noting that this technique also works for the new randomized 10 character serial numbers for Apple Silicon Macs, but the local Marketing Model Name will always be retrieved instead on Apple Silicon Macs.

				local serial_search_results_json
				serial_search_results_json="$(curl -m 5 -sL "https://km.support.apple.com/kb/index?page=categorydata&serialnumber=${SERIAL_NUMBER}" 2> /dev/null)"

				if [[ "${serial_search_results_json}" == *'"id":'* ]]; then # A valid JSON structure containing an "id" key should always be returned, even for invalid serials.
					possible_marketing_model_name="$(OSASCRIPT_ENV_JSON="${serial_search_results_json}" osascript -l 'JavaScript' -e 'JSON.parse($.NSProcessInfo.processInfo.environment.objectForKey("OSASCRIPT_ENV_JSON").js).name' 2> /dev/null)" # Parsing JSON with JXA: https://paulgalow.com/how-to-work-with-json-api-data-in-macos-shell-scripts

					if [[ "${possible_marketing_model_name}" == *'Mac'* ]]; then
						if $DEBUG_LOGGING; then >&2 echo 'DEBUG - LOADED FROM "Specs Search" URL API'; fi
						marketing_model_name="${possible_marketing_model_name}"
						load_fallback_marketing_model_name=false
					else
						if $DEBUG_LOGGING; then >&2 echo "DEBUG - INVALID FROM \"Specs Search\" URL API (${possible_marketing_model_name:-N/A}): $(echo "${serial_search_results_json}" | tr -d '[:space:]')"; fi # Remove all whitespace from JSON results just for a brief DEBUG display.

						marketing_model_name="${MODEL_IDENTIFIER} (Invalid Serial Number for Marketing Model Name)"
						load_fallback_marketing_model_name=true
					fi
				elif $DEBUG_LOGGING; then
					>&2 echo 'DEBUG - FAILED TO LOAD FROM "Specs Search" URL API'
				fi
			fi

			if ! $load_fallback_marketing_model_name; then
				if [[ -n "${marketing_model_name}" ]]; then
					if ! $marketing_model_name_was_cached; then
						# Cache the Marketing Model Name into the "About This Mac" preference key...
							# for the current user, if there is a current user (whether or not running as root), and the Marketing Model Name was downloaded or was loaded from another users cache,
							# OR for the first valid home folder detected if running as root and there is no current user and the Marketing Model Name was downloaded.

						local cpu_name_key_for_serial="${model_characters_of_serial_number}-en-US_US"
						local quoted_marketing_model_name_for_defaults
						quoted_marketing_model_name_for_defaults="$([[ "${marketing_model_name}" =~ [\(\)] ]] && echo "'${marketing_model_name}'" || echo "${marketing_model_name}")"
						# If the model contains parentheses, "defaults write" has trouble with it and the value needs to be specially quoted: https://apple.stackexchange.com/questions/300845/how-do-i-handle-e-g-correctly-escape-parens-in-a-defaults-write-key-val#answer-300853

						if [[ "${EUID:-$(id -u)}" == '0' ]]; then
							local user_id_for_cache
							local user_name_for_cache
							if [[ -n "${current_user_name}" ]]; then # Always cache for current user if there is one.
								user_id_for_cache="${current_user_id}"
								user_name_for_cache="${current_user_name}"
							else # Otherwise cache to first valid home folder detected.
								for this_home_folder in '/Users/'*; do
									if [[ -d "${this_home_folder}" && "${this_home_folder}" != '/Users/Shared' && "${this_home_folder}" != '/Users/Guest' ]]; then
										user_name_for_home="$(dscl /Search -search /Users NFSHomeDirectory "${this_home_folder}" | awk '{ print $1; exit }')"

										if [[ -n "${user_name_for_home}" ]]; then
											user_id_for_home="$(dscl -plist /Search -read "/Users/${user_name_for_home}" UniqueID 2> /dev/null | xmllint --xpath '//string[1]/text()' - 2> /dev/null)"

											if [[ -n "${user_id_for_home}" && "${user_id_for_home}" != '0' ]]; then
												user_id_for_cache="${user_id_for_home}"
												user_name_for_cache="${user_name_for_home}"
												break
											fi
										fi
									fi
								done
							fi

							if [[ -n "${user_id_for_cache}" && "${user_name_for_cache}" != '0' && -n "${user_name_for_cache}" ]]; then
								launchctl asuser "${user_id_for_cache}" sudo -u "${user_name_for_cache}" defaults write com.apple.SystemProfiler 'CPU Names' -dict-add "${cpu_name_key_for_serial}" "${quoted_marketing_model_name_for_defaults}"

								if $DEBUG_LOGGING; then
									>&2 echo "DEBUG - CACHED FOR ${user_name_for_cache}"
									>&2 launchctl asuser "${user_id_for_cache}" sudo -u "${user_name_for_cache}" defaults read com.apple.SystemProfiler 'CPU Names'
								fi
							elif $DEBUG_LOGGING; then
								>&2 echo 'DEBUG - NO USERS TO CACHE FOR'
							fi
						else
							defaults write com.apple.SystemProfiler 'CPU Names' -dict-add "${cpu_name_key_for_serial}" "${quoted_marketing_model_name_for_defaults}"

							if $DEBUG_LOGGING; then
								>&2 echo 'DEBUG - CACHED FOR CURRENT USER'
								>&2 defaults read com.apple.SystemProfiler 'CPU Names'
							fi
						fi
					fi
				else
					marketing_model_name="${MODEL_IDENTIFIER} (Internet Required for Marketing Model Name)"
					load_fallback_marketing_model_name=true
				fi
			fi
		else
			marketing_model_name="${MODEL_IDENTIFIER} (Invalid Serial Number for Marketing Model Name)"
			load_fallback_marketing_model_name=true
		fi

		if $load_fallback_marketing_model_name; then
			# A slightly different Marketing Model Name is available locally for all Intel Macs except for the last few models: https://scriptingosx.com/2017/11/get-the-marketing-name-for-a-mac/
			# Since these are not the same a what is loaded in "About This Mac", these are only used as a fallback option and are never cached.
			local si_machine_attributes_plist_path='/System/Library/PrivateFrameworks/ServerInformation.framework/Versions/A/Resources/en.lproj/SIMachineAttributes.plist' # The path to this file changed to this in macOS 10.15 Catalina.
			if [[ ! -f "${si_machine_attributes_plist_path}" ]]; then si_machine_attributes_plist_path='/System/Library/PrivateFrameworks/ServerInformation.framework/Versions/A/Resources/English.lproj/SIMachineAttributes.plist'; fi

			if [[ -f "${si_machine_attributes_plist_path}" ]]; then
				local fallback_marketing_model_name
				fallback_marketing_model_name="$(PlistBuddy -c "Print :${MODEL_IDENTIFIER}:_LOCALIZABLE_:marketingModel" "${si_machine_attributes_plist_path}" 2> /dev/null)"

				if [[ -n "${fallback_marketing_model_name}" ]]; then
					marketing_model_name+=" / Fallback: ${fallback_marketing_model_name}"
				fi
			fi
		fi

		if $MAC_IS_VIRTUAL_MACHINE; then
			marketing_model_name="Intel Virtual Machine: ${marketing_model_name}"
		fi
	fi

	if $ALWAYS_INCLUDE_MODEL_ID && [[ "${marketing_model_name}" != *"${MODEL_IDENTIFIER}"* ]]; then
		marketing_model_name+=" / ${MODEL_IDENTIFIER}"
	fi

	if $INCLUDE_MODEL_PART_NUMBER && { $IS_APPLE_SILICON || [[ -n "$(ioreg -rc AppleUSBDevice -n 'Apple T2 Controller' -d 1)" ]]; }; then # The "M####LL/A" style Model Part Number is only be accessible in software on Apple Silicon or T2 Macs.
		local possible_model_part_number
		possible_model_part_number="$(/usr/libexec/remotectl dumpstate | awk '($1 == "RegionInfo") { if ($NF == "=>") { region_info = "LL/A" } else { region_info = $NF } } ($1 == "ModelNumber") { print $NF region_info; exit }')" # I have seen a T2 Mac without any "RegionInfo" specified, so just assume "LL/A" (USA) in that case.
		if [[ "${possible_model_part_number}" == *'/'* ]]; then
			marketing_model_name+=" / ${possible_model_part_number}"
		fi
	fi

	echo "${marketing_model_name}"
}

result=$(get_marketing_model_name)

echo "<result>$result</result>"