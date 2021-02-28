# eth-its/autopkg-mac-recipes

This is a set of AutoPkg recipes used internally at ETH Zürich. These recipes may not function externally. Use at your own risk.

**For an explanation of what these recipes do, please read the [Wiki](https://github.com/eth-its/autopkg-mac-recipes/wiki).**

To add this repo to your AutoPkg setup, run the following command:

    autopkg repo-add eth-its/autopkg-mac-recipes

All these recipes are `.jamf` recipes which use `JamfUploader` processors. To use these, run the following command:

    autopkg repo-add grahampugh-recipes

Some `.jamf` recipes which more closely follow the standards used in `.jss` recipes can be found in the `grahampugh-recipes` repo.
