# Shared Processors

To use these processors, add the processor as so:

    com.github.eth-its-recipes.processors/NameOfProcessor

# JamfUploadSharepointStageCheck

## Description

This processor reads from the internal SharePoint portal used by ETH Zürich's Apple Services team and customers.

Its task is to determine whether a software title is tested and ready to promote to production.

## Input variables

-   **JSS_URL:**

    -   **required:** True
    -   **description:** Jamf Pro server URL.

-   **SP_URL:**

    -   **required:** True
    -   **description:** SharePoint Portal URL.

-   **SP_USER:**

    -   **required:** True
    -   **description:** SharePoint portal username with read privileges.

-   **SP_PASS:**

    -   **required:** True
    -   **description:** Password for the SharePoint portal username with read privileges.

-   **SELFSERVICE_POLICY_NAME:**

    -   **required:** True
    -   **description:** Name of the production Self Service policy.

-   **version:**

    -   **required:** True
    -   **description:** Version string for the last uploaded package.

## Output variables

-   **ready_to_stage:**

    -   **description:** Boolean value of whether the product is ready to be promoted to production or not.

# JamfUploadSharepointUpdater

## Description

This processor writes to the internal SharePoint portal used by ETH Zürich's Apple Services team and customers.

Its task is to update values of package versions in the portal, and to set an item to "Released to production" to indicate that a partcicular package has been promoted to production.

## Input variables

-   **JSS_URL:**

    -   **required:** True
    -   **description:** Jamf Pro server URL.

-   **SP_URL:**

    -   **required:** True
    -   **description:** SharePoint Portal URL.

-   **SP_USER:**

    -   **required:** True
    -   **description:** SharePoint portal username with read privileges.

-   **SP_PASS:**

    -   **required:** True
    -   **description:** Password for the SharePoint portal username with read privileges.

-   **POLICY_CATEGORY:**

    -   **required:** False
    -   **description:** Policy Category. Used to determine whether we are dealing with a testing recipe or a production recipe.

-   **PKG_CATEGORY:**

    -   **required:** True
    -   **description:** Package Category (which is ultimately the production policy category).

-   **LANGUAGE:**

    -   **required:** False
    -   **description:** Policy language.

-   **LICENSE:**

    -   **required:** False
    -   **description:** Policy license.

-   **MAJOR_VERSION:**

    -   **required:** False
    -   **description:** Policy major version.

-   **NAME:**

    -   **required:** True
    -   **description:** Product name.

-   **SELFSERVICE_POLICY_NAME:**

    -   **required:** True
    -   **description:** Name of the production Self Service policy.

-   **version:**

    -   **required:** True
    -   **description:** Version string for the last uploaded package.

## Output variables

None.

# LocalRepoUpdateChecker

## Description

This processor assumes that a given folder contains sub-folders which are named after the version of their contents. The idea is that there is a single package, DMG or other installer inside the folder. The list of full paths to files in folders is generated using the `SubDirectoryList` processor, so this processor won't work unless `SubDirectoryList` is earlier in the list of procvesses.

If the subfolders have multiple contents, for example due to different language packs or some other variable, these should be filtered using the SubDirectoryList inputs, i.e. `LANGUAGE`, `LICENSE`, `LIMITATION`, `EXCEPTION`.

## Input variables

-   **root_path:**

    -   **required:** True
    -   **description:** Repo path. Used here for comparisons.

-   **found_filenames:**

    -   **required:** True
    -   **description:** Output of `found_filenames` from the `SubDirectoryList` processor.

-   **RECIPE_CACHE_DIR:**
    -   **required:** True (assumed from AutoPkg)
    -   **description:** AutoPkg Cache directory.

## Output variables

-   **version:**

    -   **description:** The highest folder name according to LooseVersion logic.

-   **latest_file:**

    -   **description:** The filename of the highest version according to LooseVersion logic.

-   **file_exists:**

    -   **description:** Boolean to show whether the latest version is already present in the AutoPkg Cache.

-   **cached_path:**
    -   **description:** Path to the existing file in the AutoPkg Cache including filename.

# SubDirectoryList

## Description

This processor is used to generate a list of all files in folders in a path. That list is then processed by other processors such as `LocalRepoUpdateChecker`.

This processor is adapted from one written by Jesse Peterson. A newer version of that processor exists currently at [https://github.com/facebook/Recipes-for-AutoPkg/blob/master/Shared_Processors/SubDirectoryList.py](https://github.com/facebook/Recipes-for-AutoPkg/blob/master/Shared_Processors/SubDirectoryList.py).

## Input variables

-   **root_path:**

    -   **required:** True
    -   **description:** String to append to each found item name in dir.
    -   **default:** `,`

-   **suffix_string:**

    -   **required:** False
    -   **description:** The string that should replace instances of `string_to_replace`. This can be left as an empty string if the purpose is to remove instances of `string_to_replace`.
    -   **default:** `""`

-   **max_depth:**

    -   **required:** False
    -   **description:** Maximum depth of folders to iterate through.
    -   **default:** `2`

-   **LANGUAGE:**

    -   **required:** False
    -   **description:** Language of the pkg or DMG containing PKG, one of `ML`, `DE`, `EN`. Basically acts as a string filter for the name of the DMG.
    -   **default:** `""`

-   **LICENSE:**

    -   **required:** False
    -   **description:** License of the pkg or DMG containing PKG, one of `Floating`, `Node`. Basically acts as a string filter for the name of the DMG.
    -   **default:** `""`

-   **EXCEPTION:**

    -   **required:** False
    -   **description:** A string variable to exclude from the search.
    -   **default:** `""`

-   **LIMITATION:**

    -   **required:** False
    -   **description:** A string variable to require in the search.
    -   **default:** `""`

## Output variables

-   **found_filenames:**

    -   **description:** String containing a list of all files found relative to `root_path`, separated by `suffix_string`.

-   **relative_root:**
    -   **description:** Relative root path.
