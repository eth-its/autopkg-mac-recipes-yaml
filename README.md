# eth-its/autopkg-mac-recipes-yaml

This is a set of AutoPkg recipes used internally at ETH Zürich. These recipes may not function externally. Use at your own risk.

**For an explanation of what these recipes do, please read the [Wiki](https://github.com/eth-its/autopkg-mac-recipes/wiki).**

To add this repo to your AutoPkg setup, run the following command:

    autopkg repo-add eth-its/autopkg-mac-recipes-yaml

All these recipes are `.jamf` recipes (or their parents) which use `JamfUploader` processors. To use these, run the following command:

    autopkg repo-add grahampugh-recipes
    - or -
    autopkg repo-add grahampugh/recipes-yaml

Some `.jamf` recipes which more closely follow the standards used in `.jss` recipes can be found in the `grahampugh-recipes` repo.

## Recipes that require replacement values in the RecipeOverrides:

- `CLCGenomicsWorkbench.pkg.recipe.yaml` - `CLC_LICENSE_SERVER`
- `SPSSStatistics27-Floating.jamf.recipe.yaml` - `FLOATING_LICENSE_URL`
