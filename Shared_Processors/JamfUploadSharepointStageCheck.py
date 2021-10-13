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

from shareplum import Site
from requests_ntlm2 import HttpNtlmAuth
from autopkglib import Processor, ProcessorError  # type: ignore

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

    def connect_sharepoint(self, url, user, password):
        """make a connection to SharePoint"""
        auth = HttpNtlmAuth(f"d\\{user}", password)
        site = Site(url, auth=auth)
        if not site:
            self.output(site, verbose_level=3)
            raise ProcessorError("Could not connect to SharePoint")
        return site

    def build_query(self, criteria):
        """construct the query. format should be
        {'Where': ['And', ('Eq', 'Title', 'Good Title'),
                          ('Eq', 'My Other Column', 'Nice Value')]}
        See https://shareplum.readthedocs.io/en/latest/queries.html
        """
        query = {"Where": []}
        fields = ["ID"]
        # If more than one value we want all to match, so use "and".
        # With shareplum, the last criteria should not have an "and".
        # To achieve this we build the query and then reverse it
        # (this only works because/when all criteria are "and").
        # See https://github.com/jasonrollins/shareplum/issues/17#issuecomment-342823183
        first = True
        for key in criteria:
            operand, value = criteria[key]
            query["Where"].append((operand, key, value))
            fields.append(key)
            if not first:
                query["Where"].append("And")
            if first:
                first = False
        query["Where"].reverse()
        self.output(query, verbose_level=3)
        return fields, query

    def check_jamf_content_list(self, site, product_name, version):
        """Check the version against the untested version in the 'Jamf Content List' list"""
        listname = "Jamf Content List"
        sp_list = site.List(listname)

        criteria = {}
        criteria["Self Service Content"] = ["Eq", product_name]
        criteria["Untested Version"] = ["Eq", version]
        fields, query = self.build_query(criteria)

        content_list_passed = False

        if sp_list.GetListItems(fields=fields, query=query):
            content_list_passed = True
            self.output(f"Jamf Content List passed: {content_list_passed}")
        else:
            self.output(
                "Jamf Content List: No entry named "
                + product_name
                + " with version "
                + version
            )
        return content_list_passed

    def check_jamf_content_test(self, site, product_name):
        """Check against the 'Jamf Content Test' list"""
        sp_test_listname = "Jamf Content Test"
        sp_list = site.List(sp_test_listname)

        criteria = {}
        criteria["Self Service Content Name"] = ["Eq", product_name]
        criteria["Ready for Production"] = ["Eq", "Yes"]
        fields, query = self.build_query(criteria)

        content_test_passed = False
        if sp_list.GetListItems(fields=fields, query=query):
            content_test_passed = True
            self.output(f"Jamf Content Test passed: {content_test_passed}")
        else:
            self.output(
                f"Jamf Content Test: No entry named '{product_name}' with "
                "Ready for Production 'Yes'"
            )
        return content_test_passed

    def check_jamf_test_coordination(self, site, product_name):
        """Check against the 'Jamf Test Coordination' list"""
        sp_test_listname = "Jamf Test Coordination"
        sp_list = site.List(sp_test_listname)

        criteria = {}
        criteria["Self Service Content Name"] = ["Eq", product_name]
        criteria["Status"] = ["Eq", "Done"]
        criteria["Release Completed"] = ["Eq", "No"]
        fields, query = self.build_query(criteria)

        test_coordination_passed = False
        if sp_list.GetListItems(fields=fields, query=query):
            test_coordination_passed = True
            self.output(f"Jamf Test Coordination passed: {test_coordination_passed}")
        else:
            self.output(
                f"Jamf Test Coordination: No entry named '{product_name}' "
                "with Status 'Release Completed'='No'"
            )
        return test_coordination_passed

    def check_jamf_test_review(self, site, product_name, jss_url):
        """Check against the 'Jamf Test Review' list"""
        sp_test_listname = "Jamf Test Review"
        sp_list = site.List(sp_test_listname)

        criteria = {}
        criteria["Self Service Content Name"] = ["Eq", product_name]
        criteria["Ready for Production"] = ["Eq", "Yes"]
        if "tst" in jss_url:
            criteria["Release Completed TST"] = ["Eq", "No"]
        elif "prd" in jss_url:
            criteria["Release Completed PRD"] = ["Eq", "No"]
        else:
            raise ProcessorError("Invalid JSS_URL supplied.")
        fields, query = self.build_query(criteria)

        test_review_passed = False
        if sp_list.GetListItems(fields=fields, query=query):
            test_review_passed = True
            self.output(f"Jamf Test Review passed: {test_review_passed}")
        else:
            if "tst" in jss_url:
                self.output(
                    f"Jamf Test Review: No entry named '{product_name}' with"
                    + "'Release Completed TST' = No"
                )
            elif "prd" in jss_url:
                self.output(
                    f"Jamf Test Review: No entry named '{product_name}' with"
                    + "'Release Completed PRD' = No"
                )
        return test_review_passed

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
            if self.check_jamf_content_list(
                site, selfservice_policy_name, version
            ) and self.check_jamf_test_review(site, sharepoint_policy_name, jss_url):
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
