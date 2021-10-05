#!/usr/local/autopkg/python

"""
Copyright 2017 Graham Pugh

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""


from autopkglib import Processor  # type: ignore

__all__ = ["JamfUploadSharepointUpdater"]


class JamfUploadSharepointUpdater(Processor):
    description = (
        "Performs actions on a SharePoint site based on output of a JSSImporter run."
    )
    input_variables = {
        "JSS_URL": {
            "required": True,
            "description": (
                "The JSS URL." "This can be set in the com.github.autopkg preferences"
            ),
        },
        "SP_URL": {
            "required": True,
            "description": (
                "The SharePoint URL."
                "This can be set in the com.github.autopkg preferences"
            ),
        },
        "SP_USER": {
            "required": True,
            "description": (
                "The SharePoint user that has access to the Sharepoint path."
                "This can be set in the com.github.autopkg preferences"
            ),
        },
        "SP_PASS": {
            "required": True,
            "description": (
                "The SharePoint user's password."
                "This can be set in the com.github.autopkg "
                "preferences"
            ),
        },
        "POLICY_CATEGORY": {
            "required": False,
            "description": ("Policy Category."),
            "default": "Untested",
        },
        "PKG_CATEGORY": {
            "required": True,
            "description": (
                "Package Category (which is ultimately the prod category)."
            ),
        },
        "LANGUAGE": {"required": False, "description": "Policy language."},
        "LICENSE": {"required": False, "description": "Package license type."},
        "MAJOR_VERSION": {"required": False, "description": "Policy major version."},
        "NAME": {"required": True, "description": "Product name."},
        "SELFSERVICE_POLICY_NAME": {
            "required": False,
            "description": ("Product production policy name."),
        },
        "version": {"required": True, "description": "Product version."},
    }
    output_variables = {}

    __doc__ = description

    def main(self):
        """Do the main thing"""
        policy_category = self.env.get("POLICY_CATEGORY")
        category = self.env.get("PKG_CATEGORY")
        version = self.env.get("version")
        name = self.env.get("NAME")
        selfservice_policy_name = self.env.get("SELFSERVICE_POLICY_NAME")
        policy_language = self.env.get("LANGUAGE")
        policy_license = self.env.get("LICENSE")
        major_version = self.env.get("MAJOR_VERSION")
        jss_url = self.env.get("JSS_URL")

        # section for untested recipes (PRD server only)
        if not selfservice_policy_name:
            if "prd" in jss_url:
                selfservice_policy_name = name
                if major_version:
                    selfservice_policy_name = (
                        selfservice_policy_name + " " + major_version
                    )
                if policy_language:
                    selfservice_policy_name = (
                        selfservice_policy_name + " " + policy_language
                    )
                if policy_license:
                    selfservice_policy_name = (
                        selfservice_policy_name + " " + policy_license
                    )

                policy_name = f"{selfservice_policy_name} (Testing)"
                sharepoint_policy_name = (
                    f"{selfservice_policy_name} (Testing) v{version}"
                )

                self.output(
                    "UNTESTED recipe type: "
                    "Sending updates to SharePoint based on Policy Name "
                    f"{selfservice_policy_name} (DISABLED AT PRESENT)"
                )

                self.output("Name: %s" % name)
                self.output("Title: %s" % selfservice_policy_name)
                self.output("Policy: %s" % policy_name)
                self.output("Version: %s" % version)
                self.output("SharePoint item: %s" % sharepoint_policy_name)
                self.output("Production Category: %s" % category)
                self.output("Current Category: %s" % policy_category)

        # section for prod recipes
        else:
            sharepoint_policy_name = f"{selfservice_policy_name} (Testing) v{version}"

            self.output("Name: %s" % name)
            self.output("Policy: %s" % selfservice_policy_name)
            self.output("Version: %s" % version)
            self.output("SharePoint item: %s" % sharepoint_policy_name)
            self.output("Production Category: %s" % category)
            self.output("Current Category: %s" % policy_category)

            self.output(
                "PROD recipe type: Sending staging instructions to SharePoint "
                "(DISABLED AT PRESENT)"
            )


if __name__ == "__main__":
    PROCESSOR = JamfUploadSharepointUpdater()
    PROCESSOR.execute_shell()
