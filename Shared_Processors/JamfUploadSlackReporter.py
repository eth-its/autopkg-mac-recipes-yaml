#!/usr/bin/python

"""
Copyright 2020 Graham Pugh

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

import json

from autopkglib import (
    ProcessorError,
    URLGetter,
)  # pylint: disable=import-error


__all__ = ["JamfUploadSlackReporter"]


class JamfUploadSlackReporter(URLGetter):
    description = (
        "Posts to Slack via webhook based on output of a JamfPolicyUploader process. "
        "Takes elements from "
        "https://gist.github.com/devStepsize/b1b795309a217d24566dcc0ad136f784 "
        "and "
        "https://github.com/autopkg/nmcspadden-recipes/blob/master/PostProcessors/Yo.py"
    )
    input_variables = {
        "JSS_URL": {"required": False, "description": ("JSS_URL.")},
        "POLICY_CATEGORY": {"required": False, "description": ("Policy Category.")},
        "PKG_CATEGORY": {"required": False, "description": ("Package Category.")},
        "policy_name": {
            "required": False,
            "description": ("Untested product name from a jamf recipe."),
        },
        "SELFSERVICE_POLICY_NAME": {
            "required": False,
            "description": ("Staged product name."),
        },
        "NAME": {"required": False, "description": ("Generic product name.")},
        "version": {"required": False, "description": ("Product version.")},
        "recipe_type": {"required": False, "description": ("Recipe type (prod).")},
        "pkg_name": {"required": False, "description": ("Package in policy.")},
        "webhook_url": {"required": False, "description": ("Slack webhook.")},
        "username": {
            "required": False,
            "description": ("Slack message display name."),
            "default": "AutoPkg",
        },
        "title": {
            "required": False,
            "description": ("Slack message title."),
            "default": "",
        },
        "slack_icon_url": {
            "required": False,
            "description": ("Slack display icon URL."),
            "default": (
                "https://www.ethz.ch/services/en/service/communication/social-media"
                "/social-media-icons/_jcr_content/par/textimage_1/"
                "image.imageformat.textsingle.757918606.jpg"
            ),
        },
    }
    output_variables = {}

    __doc__ = description

    def main(self):
        """Do the main thing"""
        jss_url = self.env.get("JSS_URL")
        recipe_type = self.env.get("recipe_type")
        policy_category = self.env.get("POLICY_CATEGORY")
        category = self.env.get("PKG_CATEGORY")
        policy_name = self.env.get("policy_name")
        name = self.env.get("NAME")
        selfservice_policy_name = self.env.get("SELFSERVICE_POLICY_NAME")
        version = self.env.get("version")
        pkg_name = self.env.get("pkg_name")
        title = self.env.get("title")
        policy_language = self.env.get("POLICY_LANGUAGE")
        policy_license = self.env.get("POLICY_LICENSE")
        major_version = self.env.get("MAJOR_VERSION")

        username = self.env.get("username")
        slack_icon_url = self.env.get("slack_icon_url")
        webhook_url = self.env.get("webhook_url") or (
            "https://hooks.slack.com/services/T09466BD3/"
            "BPMUE6UVA/ZVi08WTPBfcdEu3FwnKwVCza"
        )

        # section for prod policies
        if recipe_type == "prod":
            untested_policy_name = f"{selfservice_policy_name} (Testing)"

            if not title:
                title = "Item staged to Production"
            self.output(f"Message Title: {title}")
            self.output(f"JSS address: {jss_url}")
            self.output(f"Title: {selfservice_policy_name}")
            self.output(f"Untested policy: {untested_policy_name}")
            self.output(f"Version: {version}")
            self.output(f"Production Category: {category}")

            if pkg_name:
                slack_text = (
                    f"*{title}:*\n"
                    + f"JSS address: {jss_url}\n"
                    + f"Title: *{selfservice_policy_name}*\n"
                    + f"Version: *{version}*\n"
                    + f"Category: *{category}*\n"
                    + f"Uploaded Package Name: *{pkg_name}*"
                )
            else:
                slack_text = (
                    f"*{title}:*\n"
                    + f"JSS address: {jss_url}\n"
                    + f"Title: *{selfservice_policy_name}*\n"
                    + f"Version: *{version}*\n"
                    + f"Category: *{category}*"
                )
 
        elif recipe_type == "uninstaller":
            if not title:
                title = "Uninstaller Staged"
            self.output(f"Message Title: {title}")
            self.output(f"JSS address: {jss_url}")
            self.output(f"Title: {selfservice_policy_name}")
            slack_text = (
                f"*{title}:*\n"
                + f"JSS address: {jss_url}\n"
                + f"Title: *{selfservice_policy_name}*\n"
            )

        # section for untested recipes
        else:
            selfservice_policy_name = name
            if major_version:
                selfservice_policy_name = selfservice_policy_name + " " + major_version
            if policy_language:
                selfservice_policy_name = (
                    selfservice_policy_name + " " + policy_language
                )
            if policy_license:
                selfservice_policy_name = selfservice_policy_name + " " + policy_license

            if pkg_name:
                if not title:
                    title = "New Package added to JSS"

                slack_text = (
                    f"*{title}:*\n"
                    + f"JSS address: {jss_url}\n"
                    + f"Title: *{selfservice_policy_name}*\n"
                    + f"Version: *{version}*\n"
                    + f"Category: *{category}*\n"
                    + f"Policy Name: *{policy_name}*\n"
                    + f"Package: *{pkg_name}*"
                )
            else:
                if not title:
                    title = "New Item added to JSS"

                slack_text = (
                    f"*{title}:*\n"
                    + f"JSS address: {jss_url}\n"
                    + f"Title: *{selfservice_policy_name}*\n"
                    + f"Version: *{version}*\n"
                    + f"Category: *{category}*\n"
                    + f"Policy Name: *{policy_name}*\n"
                    + "No new package uploaded"
                )

            self.output(f"Message Title: {title}")
            self.output("JSS address: %s" % jss_url)
            self.output("Title: %s" % selfservice_policy_name)
            self.output("Policy: %s" % policy_name)
            self.output("Version: %s" % version)
            self.output("Package: %s" % pkg_name)
            self.output("Production Category: %s" % category)
            self.output("Current Category: %s" % policy_category)

        # create the json data to be sent
        slack_data = {
            "text": slack_text,
            "username": username,
            "icon_url": slack_icon_url,
        }
        json_data = json.dumps(slack_data)

        # Build the required curl switches
        curl_opts = [
            "--data",
            json_data,
            "--header",
            "Content-Type: application/json",
            "--request",
            "POST",
            "--show-error",
            "--silent",
            webhook_url,
        ]

        # Initialize the curl_cmd, add the curl options, and execute the curl
        try:
            curl_cmd = self.prepare_curl_cmd()
            curl_cmd.extend(curl_opts)
            response = self.download_with_curl(curl_cmd)
            self.output(response, verbose_level=3)

        except Exception:
            raise ProcessorError("Failed to complete the post")  # noqa


if __name__ == "__main__":
    PROCESSOR = JamfUploadSlackReporter()
    PROCESSOR.execute_shell()
