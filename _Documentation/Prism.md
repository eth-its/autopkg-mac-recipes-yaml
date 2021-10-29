# Prism

- Prism package is obtained from `com.github.rtrouton.download.Prism`.
- The license key is however obtained from the ETH IT Shop (see `ITShopUpdateChecker` in `Prism.pkg` recipe).
- The license key is placed into `Prism-postinstall.sh`.
- The recipe may need to be force-pushed annually when the license key is renewed.

## Current icon

- Icon for Prism 9 is "Prism 9.png"

## Updating the license key existing installations

- To allow existing installations to have the license key updated, we have the Script-only recipe, `PrismPolicyLicense-script.jamf`.
- This creates a Once-per-computer policy scoped to computers in `Prism EN installed`.
- This policy needs to be run once the new license is available in the IT Shop.
