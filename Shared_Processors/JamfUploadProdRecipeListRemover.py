#!/usr/local/autopkg/python

"""
Copyright 2021 Graham Pugh

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

NOTES:
Set the webhook_url to the one provided by Slack when you create the webhook at
https://my.slack.com/services/new/incoming-webhook/
"""


import os

from autopkglib import Processor, ProcessorError  # pylint: disable=import-error


__all__ = ["JamfUploadProdRecipeListRemover"]


class JamfUploadProdRecipeListRemover(Processor):
    description = (
        "Creates a recipe list for nodes recipes from completed untested recipes"
    )
    input_variables = {
        "RECIPE_PATH": {
            "required": True,
            "description": ("Path of recipe that is being run."),
        },
        "SELFSERVICE_POLICY_NAME": {
            "required": False,
            "description": ("Staged product name."),
        },
        "prod_recipe_list_path": {
            "required": False,
            "description": ("Path of recipe list to edit."),
        },
        "recipe_type": {"required": False, "description": ("Recipe type (prod).")},
    }
    output_variables = {}

    __doc__ = description

    def main(self):
        """Do the main thing"""
        recipe_path = self.env.get("RECIPE_PATH")
        recipe_type = self.env.get("recipe_type")
        prod_recipe_list_path = self.env.get("prod_recipe_list_path")
        selfservice_policy_name = self.env.get("SELFSERVICE_POLICY_NAME")

        if recipe_type == "prod" and selfservice_policy_name:
            # extract recipe name from path
            recipe_file = os.path.basename(recipe_path)
            recipe_name = recipe_file.replace("-prod.jamf.recipe.yaml", "-prod.jamf")

            # now write to the nodes recipe list
            try:
                with open(prod_recipe_list_path, "r") as file:
                    lines = file.readlines()

                # delete matching content
                with open(prod_recipe_list_path, "w") as file:
                    for line in lines:
                        # readlines() includes a newline character
                        if line.strip("\n") != recipe_name:
                            file.write(line)
                self.output(f"Removed {recipe_name} from {recipe_file}")
            except Exception:
                raise ProcessorError("Could not write to recipe list")
        else:
            self.output("Nothing to do.")


if __name__ == "__main__":
    PROCESSOR = JamfUploadProdRecipeListRemover()
    PROCESSOR.execute_shell()
