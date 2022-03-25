#!/bin/bash


################################################################################
#
# SOURCE
# https://github.com/Daz-wallace/blog-snippets/tree/master/Mass-Deploying%20Settings%20for%20Atom
#
# DESCRIPTION
# Loops through the /Users and User Template folders, pre-configuring Atom with:
#	-	Auto Update disabled
#	-	Do not sure Welcome screen on start up
#	-	Do not consent (or show) Telemetry screen
#
################################################################################

################################################################################
######################### Global Variables #####################################
################################################################################

setupInitContents="atom.config.set('welcome.showOnStartup', 'false')
atom.config.set('core.automaticallyUpdate', 'false')
atom.config.set('core.telemetryConsent', 'no')
"
################################################################################
########################### Script #############################################
################################################################################

### Loop through user's homes and setup config script:

for userHome in /Users/* ;  do
	userUID=$(basename "${userHome}")
	if [ ! "${userUID}" = "Shared" ] ; then
		/bin/echo "Home folder is not Shared, continuing..."
		if [ ! -d "${userHome}"/.atom ] ; then
			/bin/echo ".atom folder doesn't exist, creating..."
        	/bin/mkdir -p "${userHome}"/.atom
        	/usr/sbin/chown "${userUID}" "${userHome}"/.atom
      	fi
      	if [ -d "${userHome}"/.atom ]; then
			/bin/echo "${setupInitContents}" | /usr/bin/tee -a "${userHome}"/.atom/init.coffee
      		/usr/sbin/chown root "${userHome}"/.atom/init.coffee
      		/bin/chmod 755 "${userHome}"/.atom/init.coffee
      	fi
	fi
done

### Loop through the user templates and setup config script:

for userTemplate in "/System/Library/User Template"/* ;  do
	if [ ! -d "${userTemplate}"/.atom ]; then
		mkdir -p "${userTemplate}"/.atom
	fi
	if [ -d "${userTemplate}"/.atom ]; then
		/bin/echo "${setupInitContents}" | /usr/bin/tee -a "${userTemplate}"/.atom/init.coffee
    fi
done
