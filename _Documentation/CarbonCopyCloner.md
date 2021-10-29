# Carbon Copy Cloner

Carbon Copy Cloner requires a configuration profile containing the license key.

`CarbonCopyCloner-profile.jamf` creates this profile.

Since we do not want to include the license information in a public repo, the following keys need to be supplied in the RecipeOverride on the AutoPkg server:

- `REGISTRATION_CODE`
- `REGISTRATION_EMAIL`
- `REGISTRATION_NAME`
- `REGISTRATION_PRODUCT_NAME`

Note that during release of a new version, we need separate profile for the testing version and the prod version, because the codes will be different.
