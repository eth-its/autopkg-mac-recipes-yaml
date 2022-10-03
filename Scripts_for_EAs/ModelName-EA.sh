#!/bin/bash

get_marketing_model_name() {
	##
	## Created by Pico Mitchell (of Free Geek)
	##
	## Version: 2022.5.19-1
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
	local marketing_model_name

	local debug_logging=false # Set to "true" for logging to stderr to see how the Marketing Model Name is being loaded and if and where it is being cached.

	if [[ "$(sysctl -in hw.optional.arm64)" == '1' ]]; then
		# This local Marketing Model Name within "ioreg" only exists on Apple Silicon Macs.
		if $debug_logging; then >&2 echo 'DEBUG - LOADING FROM IOREG ON APPLE SILICON'; fi
		marketing_model_name="$(PlistBuddy -c 'Print :0:product-name' /dev/stdin <<< "$(ioreg -arc IOPlatformDevice -k product-name)" 2> /dev/null | tr -cd '[:print:]')" # Remove non-printable characters because this decoded value could end with a null char.
	else
		#local system_profiler_hardware_info
		#system_profiler_hardware_info="$(system_profiler -xml SPHardwareDataType)" # Loading this one "system_profiler" data type takes TWICE as long as using "ioreg" for the Serial Number and "sysctl" for the Model Identifier.

		local serial_number
		#serial_number="$(PlistBuddy -c 'Print :0:_items:0:serial_number' /dev/stdin <<< "${system_profiler_hardware_info}" 2> /dev/null)"
		serial_number="$(PlistBuddy -c 'Print :0:IOPlatformSerialNumber' /dev/stdin <<< "$(ioreg -arc IOPlatformExpertDevice -k IOPlatformSerialNumber -d 1)" 2> /dev/null)"

		local model_identifier
		#model_identifier="$(PlistBuddy -c 'Print :0:_items:0:machine_model' /dev/stdin <<< "${system_profiler_hardware_info}" 2> /dev/null)"
		model_identifier="$(sysctl -n hw.model 2> /dev/null)" # The Model Identifier could also be retrieved from the same "ioreg" class as the Serial Number, but using "sysctl" is actually faster than saving the "ioreg" output to a variable and parsing it through "PlistBuddy" again to get the Model Identifier.
		if [[ -z "${model_identifier}" ]]; then model_identifier='UNKNOWN Model Identifier'; fi # This should never happen, but will result in some useful feedback if somehow "sysctl" fails to return a Model Identifier.

		local short_model_name
		#short_model_name="$(PlistBuddy -c 'Print :0:_items:0:machine_name' /dev/stdin <<< "${system_profiler_hardware_info}" 2> /dev/null)"
		short_model_name="${model_identifier//[0-9,]/}" # BUT, there is no way to get the Short Model Name (like "MacBook Pro") without using "system_profiler", so it's faster to create it from the model_identifier.
		short_model_name_end_components=( 'Pro' 'Air' 'mini' ) # IMPORTANT NOTE: Creating the Short Model Name this way IS NOT future-proof IF Apple ever adds another model suffix (which seems unlikely but isn't impossible). If that is a concern, you can use the commented out "system_profiler" code instead.
		for this_short_model_name_end_component in "${short_model_name_end_components[@]}"; do
			if [[ "${short_model_name}" == *"${this_short_model_name_end_component}" ]]; then
				short_model_name="${short_model_name/${this_short_model_name_end_component}/ ${this_short_model_name_end_component}}"
				break
			fi
		done

		local load_fallback_marketing_model_name=false

		if (( ${#serial_number} >= 11 )); then
			# The model part of the Serial Number is the last 4 characters for 12 character serials and the last 3 characters for 11 character serials (which are very old and shouldn't actually be encountered: https://www.macrumors.com/2010/04/16/apple-tweaks-serial-number-format-with-new-macbook-pro/).
			# Starting with the 2021 MacBook Pro models, randomized 10 character Serial Numbers are now used which do not have any model specific characters, but those Macs will never get here or need to load the Marketing Model Name over the internet since they are Apple Silicon and the local Marketing Model Name will have been retrieved above.
			local model_characters_of_serial_number="${serial_number:8}"
			local marketing_model_name_was_cached=false
			local possible_marketing_model_name

			if [[ "${EUID:-$(id -u)}" == '0' ]]; then # If running as root, check for the cached Marketing Model Name from the current user and if not found check for it from any and all other users.
				local current_user_id
				current_user_id="$(scutil <<< 'show State:/Users/ConsoleUser' | awk '($1 == "UID") { print $NF; exit }')"
				local current_user_name
				if [[ "${current_user_id}" && "${current_user_id}" != '0' ]]; then
					current_user_name="$(dscl /Search -search /Users UniqueID "${current_user_id}" | awk '{ print $1; exit }')"
				fi

				if [[ -n "${current_user_name}" ]]; then # Always check cached preferences for current user first so that we know whether or not it needs to be cached for the current user if it is already cached for another user.
					if $debug_logging; then >&2 echo "DEBUG - CHECKING CURRENT USER ${current_user_name} DEFAULTS"; fi
					# Since "defaults read" has no option to traverse into keys of dictionary values, use the whole "defaults export" output and parse it with "PlistBuddy" to get at the specific key of the "CPU Names" dictionary value that we want.
					# Using "defaults export" instead of accessing the plist file directly with "PlistBuddy" is important since preferences are not guaranteed to be written to disk if they were just set.
					possible_marketing_model_name="$(PlistBuddy -c "Print :'CPU Names':${model_characters_of_serial_number}-en-US_US" /dev/stdin <<< "$(launchctl asuser "${current_user_id}" sudo -u "${current_user_name}" defaults export com.apple.SystemProfiler -)" 2> /dev/null)"

					if [[ -n "${possible_marketing_model_name}" && "${possible_marketing_model_name}" == "${short_model_name}"* ]]; then
						if $debug_logging; then >&2 echo "DEBUG - LOADED FROM CURRENT USER ${current_user_name} CACHE"; fi
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
								user_id_for_home="$(PlistBuddy -c 'Print :dsAttrTypeStandard\:UniqueID:0' /dev/stdin <<< "$(dscl -plist /Search -read "/Users/${user_name_for_home}" UniqueID 2> /dev/null)" 2> /dev/null)"

								if [[ -n "${user_id_for_home}" && "${user_id_for_home}" != '0' && ( -z "${current_user_name}" || "${current_user_name}" != "${user_name_for_home}" ) ]]; then # No need to check current user in this loop since it was already checked.
									if $debug_logging; then >&2 echo "DEBUG - CHECKING ${this_home_folder} DEFAULTS"; fi
									possible_marketing_model_name="$(PlistBuddy -c "Print :'CPU Names':${model_characters_of_serial_number}-en-US_US" /dev/stdin <<< "$(launchctl asuser "${user_id_for_home}" sudo -u "${user_name_for_home}" defaults export com.apple.SystemProfiler -)" 2> /dev/null)" # See notes above about using "PlistBuddy" with "defaults export".

									if [[ -n "${possible_marketing_model_name}" && "${possible_marketing_model_name}" == "${short_model_name}"* ]]; then
										if $debug_logging; then >&2 echo "DEBUG - LOADED FROM ${this_home_folder} CACHE"; fi
										marketing_model_name="${possible_marketing_model_name}"

										if [[ -z "${current_user_name}" ]]; then # DO NOT consider the Marketing Model Name cached if there is a current user that it was not cached for so that it can be cached to the current user.
											marketing_model_name_was_cached=true
										elif $debug_logging; then
											>&2 echo 'DEBUG - NOT CONSIDERING IT CACHED SINCE THERE IS A CURRENT USER'
										fi

										break
									fi
								elif $debug_logging; then
									>&2 echo "DEBUG - SKIPPING ${this_home_folder} SINCE IS CURRENT USER"
								fi
							fi
						fi
					done
				fi
			else # If running as a user, won't be able to check others home folders, so only check current user preferences.
				if $debug_logging; then >&2 echo 'DEBUG - CHECKING CURRENT USER DEFAULTS'; fi
				possible_marketing_model_name="$(PlistBuddy -c "Print :'CPU Names':${model_characters_of_serial_number}-en-US_US" /dev/stdin <<< "$(defaults export com.apple.SystemProfiler -)" 2> /dev/null)" # See notes above about using "PlistBuddy" with "defaults export".

				if [[ -n "${possible_marketing_model_name}" && "${possible_marketing_model_name}" == "${short_model_name}"* ]]; then
					if $debug_logging; then >&2 echo 'DEBUG - LOADED FROM CURRENT USER CACHE'; fi
					marketing_model_name="${possible_marketing_model_name}"
					marketing_model_name_was_cached=true
				fi
			fi

			if [[ -z "${marketing_model_name}" ]]; then
				local marketing_model_name_xml
				marketing_model_name_xml="$(curl -m 5 -sL "https://support-sp.apple.com/sp/product?cc=${model_characters_of_serial_number}" 2> /dev/null)"

				if [[ -n "${marketing_model_name_xml}" ]]; then
					possible_marketing_model_name="$(xmllint --xpath '//configCode/text()' <(echo "${marketing_model_name_xml}") 2> /dev/null)"

					if [[ -n "${possible_marketing_model_name}" && "${possible_marketing_model_name}" == "${short_model_name}"* ]]; then
						if $debug_logging; then >&2 echo 'DEBUG - LOADED FROM CURL'; fi
						marketing_model_name="${possible_marketing_model_name}"
					elif $debug_logging; then
						>&2 echo 'DEBUG - INVALID FROM CURL'
					fi
				elif $debug_logging; then
					>&2 echo 'DEBUG - FAILED TO LOAD FROM CURL'
				fi
			fi

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
										user_id_for_home="$(PlistBuddy -c 'Print :dsAttrTypeStandard\:UniqueID:0' /dev/stdin <<< "$(dscl -plist /Search -read "/Users/${user_name_for_home}" UniqueID 2> /dev/null)" 2> /dev/null)"

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

							if $debug_logging; then
								>&2 echo "DEBUG - CACHED FOR ${user_name_for_cache}"
								>&2 launchctl asuser "${user_id_for_cache}" sudo -u "${user_name_for_cache}" defaults read com.apple.SystemProfiler 'CPU Names'
							fi
						elif $debug_logging; then
							>&2 echo 'DEBUG - NO USERS TO CACHE FOR'
						fi
					else
						defaults write com.apple.SystemProfiler 'CPU Names' -dict-add "${cpu_name_key_for_serial}" "${quoted_marketing_model_name_for_defaults}"

						if $debug_logging; then
							>&2 echo 'DEBUG - CACHED FOR CURRENT USER'
							>&2 defaults read com.apple.SystemProfiler 'CPU Names'
						fi
					fi
				fi
			else
				marketing_model_name="${model_identifier} (Internet Required for Marketing Model Name)"
				load_fallback_marketing_model_name=true
			fi
		else
			marketing_model_name="${model_identifier} (Invalid Serial Number for Marketing Model Name)"
			load_fallback_marketing_model_name=true
		fi

		if $load_fallback_marketing_model_name; then
			# A slightly different Marketing Model Name is available locally for all Intel Macs except for the last few models: https://scriptingosx.com/2017/11/get-the-marketing-name-for-a-mac/
			# Since these are not the same a what is loaded in "About This Mac", these are only used as a fallback option and are never cached.
			local si_machine_attributes_plist_path='/System/Library/PrivateFrameworks/ServerInformation.framework/Versions/A/Resources/en.lproj/SIMachineAttributes.plist' # The path to this file changed to this in macOS 10.15 Catalina.
			if [[ ! -f "${si_machine_attributes_plist_path}" ]]; then si_machine_attributes_plist_path='/System/Library/PrivateFrameworks/ServerInformation.framework/Versions/A/Resources/English.lproj/SIMachineAttributes.plist'; fi

			if [[ -f "${si_machine_attributes_plist_path}" ]]; then
				local fallback_marketing_model_name
				fallback_marketing_model_name="$(PlistBuddy -c "Print :${model_identifier}:_LOCALIZABLE_:marketingModel" "${si_machine_attributes_plist_path}" 2> /dev/null)"

				if [[ -n "${fallback_marketing_model_name}" ]]; then
					marketing_model_name+=" - Fallback: ${fallback_marketing_model_name}"
				fi
			fi
		fi
	fi

	echo "${marketing_model_name}"
}

result=$(get_marketing_model_name)

echo "<result>$result</result>"