SPSS 27 Silent Installation
=======

## Concurrent license (Floating)

Taken from [Concurrent_License_Administrator_Guide.pdf](ftp://public.dhe.ibm.com/software/analytics/spss/documentation/statistics/27.0/en/client/InstallationDocuments/MacOS/Concurrent_License_Administrator_Guide.pdf)

Use the following command to run a silent installation. On macOS you must run as root or with the sudo command.

    sudo installer -pkg IBM\ SPSS\ Statistics\ 27.pkg -target /

Note: If you want to push a silent installation on MacOS with an activated license, you must write a script that executes the silent installation command and calls the `licenseactivator` tools after the installation completes. For example:

The licenseactivator tool is installed at: `/Applications/IBM SPSS Statistics 27/Resources/Activation`.

    sudo installer -pkg IBM\ SPSS\ Statistics\ 27.pkg -target /
    cd /Applications/IBM\ SPSS\ Statistics\ 27/Resources/Activation
    ./licenseactivator LSHOST=[Server Name]

### Disabling Internet connectivity features

After installation, you can use the following command to disable Internet connectivity features (information sharing, error reporting, and welcome screen updates). The command must be run from the `/Applications/IBM SPSS Statistics 27/Resources/Configuration` directory (this is the default installation location):

    ./Configure NO

## Authorized User License (Node)

Taken from [Authorized_User_License_Administrator_Guide.pdf](ftp://public.dhe.ibm.com/software/analytics/spss/documentation/statistics/27.0/en/client/InstallationDocuments/MacOS/Authorized_User_License_Administrator_Guide.pdf)

Use the following command to run a silent installation. On macOS you must run as root or with the sudo command.

    sudo installer -pkg IBM\ SPSS\ Statistics\ 27.pkg -target /

Note: If you want to push a silent installation on MacOS with an activated license, you must write a script that executes the silent installation command and calls the `licenseactivator` tools after the installation completes. For example:

The licenseactivator tool is installed at: `/Applications/IBM SPSS Statistics 27/Resources/Activation`.

    sudo installer -pkg IBM\ SPSS\ Statistics\ 27.pkg -target /
    cd /Applications/IBM\ SPSS\ Statistics\ 27/Resources/Activation
    ./licenseactivator -c [authcode]

### Disabling Internet connectivity features

After installation, you can use the following command to disable Internet connectivity features (information sharing, error reporting, and welcome screen updates). The command must be run from the `/Applications/IBM SPSS Statistics 27/Resources/Configuration` directory (this is the default installation location):

    ./Configure NO

## Determining which license type is active

`./showlic -np` outputs whether the license is `Network` (i.e. Floating) or `Local` (i.e. Node). A Network license is preferred to a network license.

This command should therefore return a line if there is a network license, or nothing if not:

    ./showlic| head -n 6 | grep "Network license"

This command should therefore return a line if there is a local license, or nothing if not:

    ./showlic -np | head -n 6 | grep "Local license"

Note that there is a small delay in exiting this command, so it is not advisable to use as an Extension Attribute. I suggest using it during installation and writing the output elsewhere.

A local license is written as a single line in `/Applications/IBM SPSS Statistics 27/Resources/Activation/lservrc`. This is populated when `./licenseactivator -c [authcode]` is (sucessfully) run. If this file is moved, the license is no longer detected. If the file is moved back, it is once again detected. An Extension Attribute could therefore look for content in this file to determins the existence of a local license.

A network license server is written into `/Applications/IBM SPSS Statistics 27/Resources/Activation/commutelicense.ini`, which looks like:

    [Commuter]
    DaemonHost=[license-server]
    Organization=
    CommuterMaxLife=7
    [Product]
    VersionMinor=0
    VersionMajor=27

If the `DaemonHost` key is set as blank, the license server is no longer found. The `commutelicense.ini` file should remain in place, however. Line 2 of this file could therefore be used to determins the existence of a local license.
