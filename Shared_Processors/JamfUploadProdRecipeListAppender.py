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


__all__ = ["JamfUploadProdRecipeListAppender"]


class JamfUploadProdRecipeListAppender(Processor):
    description = (
        "Creates a recipe list for nodes recipes from completed untested recipes"
    )
    input_variables = {
        "RECIPE_PATH": {
            "required": True,
            "description": ("Path of recipe that is being run."),
        },
        "policy_name": {
            "required": False,
            "description": ("Untested product name from a jamf recipe."),
        },
        "prod_recipe_list_path": {
            "required": False,
            "description": ("Path of recipe list to edit."),
        },
    }
    output_variables = {}

    __doc__ = description

    def main(self):
        """Do the main thing"""
        recipe_path = self.env.get("RECIPE_PATH")
        prod_recipe_list_path = self.env.get("prod_recipe_list_path")

        if (
            ".jamf.recipe.yaml" in recipe_path
            and "-prod" not in recipe_path
            and "-nodes" not in recipe_path
        ):
            # extract recipe name from path
            recipe_file = os.path.basename(recipe_path)
            recipe_name = recipe_file.replace(".jamf.recipe.yaml", "-prod.jamf")

            # now write to the nodes recipe list
            try:
                with open(prod_recipe_list_path, "r") as file:
                    lines = file.readlines()

                for line in lines:
                    if line.strip(os.linesep) == recipe_name:
                        self.output(
                            f"{recipe_name} already in {recipe_file}; nothing to do."
                        )
                        return
            except FileNotFoundError:
                pass

            try:
                with open(prod_recipe_list_path, "a+") as file:
                    file_lines = file.readlines()
                    # ensure last line has a line break, otherwise add one
                    if file_lines:
                        if file_lines[-1] != os.linesep:
                            file.write(os.linesep)
                    # Append text at the end of file, including a line break
                    file.write(recipe_name + os.linesep)
                self.output(f"Added {recipe_name} to {prod_recipe_list_path}")
            except Exception:
                raise ProcessorError("Could not write to recipe list")
        else:
            self.output(
                f"{recipe_path} is not an untested .jamf recipe, so nothing to do."
            )


if __name__ == "__main__":
    PROCESSOR = JamfUploadProdRecipeListAppender()
    PROCESSOR.execute_shell()
