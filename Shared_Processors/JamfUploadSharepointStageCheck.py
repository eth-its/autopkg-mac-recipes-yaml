#!/usr/local/autopkg/python

"""
Copyright 2019 Graham Pugh

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

__all__ = ["JamfUploadSharepointStageCheck"]


class JamfUploadSharepointStageCheck(Processor):
    """Inputs from AutoPkg processes"""

    description = "Reports to AutoPkg whether a product is ready to stage"
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
                "This can be set in the com.github.autopkg preferences"
            ),
        },
        "SELFSERVICE_POLICY_NAME": {
            "required": False,
            "description": ("Name of production self service policy."),
        },
        "version": {
            "required": False,
            "description": ("Package version in last recipe run."),
        },
    }
    output_variables = {
        "ready_to_stage": {"description": "Outputs True or False."},
    }

    __doc__ = description

    def main(self):
        """Do the main thing"""
        selfservice_policy_name = self.env.get("SELFSERVICE_POLICY_NAME")
        version = self.env.get("version")

        self.output(
            "NOTICE: This is a temporary processor which sets ready_to_stage ALWAYS to True"
        )

        sharepoint_policy_name = f"{selfservice_policy_name} (Testing) v{version}"

        self.output(f"Untested Policy: {selfservice_policy_name} (Testing)")
        self.output(f"Untested SharePoint Item: {sharepoint_policy_name}")

        ready_to_stage = True

        self.output("Ready To Stage: {}".format(ready_to_stage))
        self.env["ready_to_stage"] = ready_to_stage


if __name__ == "__main__":
    PROCESSOR = JamfUploadSharepointStageCheck()
    PROCESSOR.execute_shell()
