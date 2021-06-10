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

from __future__ import absolute_import
import ssl

import urllib.request
from ntlm3.HTTPNtlmAuthHandler import HTTPNtlmAuthHandler
from sharepoint import SharePointSite
from autopkglib import Processor, ProcessorError  # type: ignore

ssl._create_default_https_context = ssl._create_unverified_context

__all__ = ["JamfUploadSharepointStageCheck"]


class JamfUploadSharepointStageCheck(Processor):
    """Inputs from AutoPkg processes"""

    description = "Reports to AutoPkg whether a product is ready to stage"
    input_variables = {
        "JSS_URL": {
            "required": True,
            "description": (
                "The JSS URL."
                "This can be set in the com.github.autopkg preferences"
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

    def connect_sharepoint(self, url, user, password):
        """make a connection to SharePoint"""
        pass_man = urllib.request.HTTPPasswordMgrWithDefaultRealm()
        pass_man.add_password(None, url, user, password)
        auth_ntlm = HTTPNtlmAuthHandler(pass_man)
        opener = urllib.request.build_opener(auth_ntlm)
        urllib.request.install_opener(opener)
        site = SharePointSite(url, opener)
        if not site:
            self.output(site, verbose_level=3)
            raise ProcessorError("Could not connect to SharePoint")
        return site

    def check_jamf_content_list(self, site, product_name, version):
        """Check the version against the untested version in the 'Jamf Content List' list"""
        sp_test_listname = "Jamf Content List"
        sp_list = site.lists[sp_test_listname]
        sp_product_in_list = False
        sp_content_list_passed = False
        for row in sp_list.rows:
            sp_policy_name = row.Title
            sp_untested_version = row.Untested_x0020_Version
            if sp_policy_name == product_name:
                sp_product_in_list = True
                self.output(
                    "Version in Jamf Content List: {}".format(sp_untested_version)
                )
                if sp_untested_version == version:
                    sp_content_list_passed = True
                else:
                    self.output(
                        "Jamf Content List: Versions do not match: "
                        "SharePoint: '{}'; AutoPkg: '{}".format(
                            sp_untested_version, version
                        )
                    )
        if not sp_product_in_list:
            self.output("Jamf Content List: No entry named '{}'".format(product_name))
        self.output("Jamf Content List passed: {}".format(sp_content_list_passed))
        return sp_content_list_passed

    def check_jamf_content_test(self, site, product_name):
        """Check against the 'Jamf Content Test' list"""
        sp_test_listname = "Jamf Content Test"
        sp_list = site.lists[sp_test_listname]
        sp_product_in_list = False
        sp_content_test_passed = False
        for row in sp_list.rows:
            sp_policy_name = row.Title
            sp_ready_for_production = row.Ready_x0020_for_x0020_Production
            if sp_policy_name == product_name:
                sp_product_in_list = True
                self.output(
                    "Jamf Content Test 'Ready for Production': {}".format(
                        sp_ready_for_production
                    )
                )
                if sp_ready_for_production == "Yes":
                    sp_content_test_passed = True
        if not sp_product_in_list:
            self.output("Jamf Content Test: No entry named '{}'".format(product_name))
        self.output("Jamf Content Test passed: {}".format(sp_content_test_passed))
        return sp_content_test_passed

    def check_jamf_test_coordination(self, site, product_name):
        """Check against the 'Jamf Test Coordination' list"""
        sp_test_listname = "Jamf Test Coordination"
        sp_list = site.lists[sp_test_listname]
        sp_product_in_list = False
        sp_test_coordination_passed = False
        for row in sp_list.rows:
            sp_policy_name = row.Title
            sp_status = row.Status
            sp_release_completed = row.Release_x0020_Completed
            if sp_policy_name == product_name:
                sp_product_in_list = True
                self.output("Jamf Test Coordination 'Status': {}".format(sp_status))
                self.output(
                    "Jamf Test Coordination 'Release Completed': {}".format(
                        sp_release_completed
                    )
                )
                if sp_status == "Done" and not sp_release_completed:
                    sp_test_coordination_passed = True
        if not sp_product_in_list:
            self.output(
                "Jamf Test Coordination: No entry named '{}'".format(product_name)
            )
        self.output(
            "Jamf Test Coordination passed: {}".format(sp_test_coordination_passed)
        )
        return sp_test_coordination_passed

    def check_jamf_test_review(self, site, product_name, jss_url):
        """Check against the 'Jamf Test Review' list"""
        sp_test_listname = "Jamf Test Review"
        sp_list = site.lists[sp_test_listname]
        sp_product_in_list = False
        sp_test_review_passed = False
        for row in sp_list.rows:
            sp_policy_name = row.Title
            sp_ready_for_production = row.Ready_x0020_for_x0020_Production
            sp_release_completed = row.Release_x0020_Completed
            if sp_policy_name == product_name:
                sp_product_in_list = True
                self.output(
                    "Jamf Test Review 'Ready for Production': {}".format(
                        sp_ready_for_production
                    )
                )
                self.output(
                    "Jamf Test Review 'Release Completed': {}".format(
                        sp_release_completed
                    )
                )
                if "tst" in jss_url:
                    if sp_ready_for_production and not sp_release_completed:
                        sp_test_review_passed = True
                elif "prd" in jss_url:
                    if sp_ready_for_production:
                        sp_test_review_passed = True
                else:
                    raise ProcessorError("Invalid JSS_URL supplied.")
        if not sp_product_in_list:
            self.output(f"Jamf Test Review: No entry named '{product_name}'")
        self.output(f"Jamf Test Review passed: {sp_test_review_passed}")
        return sp_test_review_passed

    def main(self):
        """Do the main thing"""
        selfservice_policy_name = self.env.get("SELFSERVICE_POLICY_NAME")
        version = self.env.get("version")
        jss_url = self.env.get("JSS_URL")
        sp_url = self.env.get("SP_URL")
        sp_user = self.env.get("SP_USER")
        sp_pass = self.env.get("SP_PASS")

        sharepoint_policy_name = f"{selfservice_policy_name} (Testing) v{version}"

        ready_to_stage = False

        self.output(f"Untested Policy: {selfservice_policy_name} (Testing)")
        self.output(f"Untested SharePoint Item: {sharepoint_policy_name}")

        # verify we have the variables we need
        if not sp_url or not sp_user or not sp_pass:
            raise ProcessorError("Insufficient SharePoint credentials supplied.")

        # connect to the sharepoint site
        site = self.connect_sharepoint(sp_url, sp_user, sp_pass)

        # check each list has the requirements met for staging
        if "tst" in jss_url:
            # tst
            if (
                self.check_jamf_content_test(site, sharepoint_policy_name)
                and self.check_jamf_content_list(site, selfservice_policy_name, version)
                and self.check_jamf_test_review(site, sharepoint_policy_name, jss_url)
            ):
                ready_to_stage = True
        elif "prd" in jss_url:
            # prd
            if (
                self.check_jamf_content_test(site, sharepoint_policy_name)
                and self.check_jamf_content_list(site, selfservice_policy_name, version)
                and self.check_jamf_test_coordination(site, sharepoint_policy_name)
                and self.check_jamf_test_review(site, sharepoint_policy_name, jss_url)
            ):
                ready_to_stage = True
        else:
            raise ProcessorError("Invalid JSS_URL supplied.")
        self.output("Ready To Stage: {}".format(ready_to_stage))
        self.env["ready_to_stage"] = ready_to_stage


if __name__ == "__main__":
    PROCESSOR = JamfUploadSharepointStageCheck()
    PROCESSOR.execute_shell()
