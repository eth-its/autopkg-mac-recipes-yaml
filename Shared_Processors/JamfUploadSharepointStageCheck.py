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

from autopkglib import Processor, ProcessorError  # type: ignore
import requests
import msal
import json
from pathlib import Path

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
        "SPO_URL": {
            "required": True,
            "description": (
                "The SharePoint Online URL."
                "This can be set in the com.github.autopkg preferences"
            ),
        },
        "SPO_USER": {
            "required": True,
            "description": (
                "The SharePoint Online App ID has access to the Sharepoint path."
                "This can be set in the com.github.autopkg preferences"
            ),
        },
        "SPO_PASS": {
            "required": True,
            "description": (
                "The SharePoint Online App's Credentials password."
                "This can be set in the com.github.autopkg preferences"
            ),
        },
        "SPO_TENANT_ID": {
            "required": True,
            "description": (
                "The SharePoint Online Tenant ID that contains the List."
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

    def acquire_token(self,spo_app_id,graph_tenant_id,spo_app_cred):
        app = msal.ConfidentialClientApplication(
            spo_app_id,
            authority=f"https://login.microsoftonline.com/{graph_tenant_id}",
            client_credential=spo_app_cred
        )
        result = app.acquire_token_for_client(scopes=["https://graph.microsoft.com/.default"])
        if "access_token" not in result: 
            raise RuntimeError(f"Token acquisition failed: {result}")
        return result["access_token"]

    def get_filtered_list_items(self,list_name, filter_odata, fields_select="ID", page_size=1): #"Title,Ready_x0020_for_x0020_Production,Release_x0020_Completed_x0020_TS"
        params = { "$top": page_size, "$filter": filter_odata, "$expand": f"fields($select={fields_select})" }
        url = f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_ids[list_name]}/items"
        headers = {"Authorization": f"Bearer {graph_token}"}
        self.output(f"querying {list_name} with {params}", verbose_level=3)
        resp = requests.get(url, headers=headers, params=params)
        if not resp.ok:
            self.output(f"GET {url} failed: {resp.status_code} {resp.text}", verbose_level=3)
            return False
        #self.output(f"GET {url} succeeded: {resp.status_code} {resp.text}", verbose_level=3)
        if len(resp.json()['value']) > 0: 
            return resp.json()['value']
        return False

    def build_query(self, criteria,list_name):
        """construct the query. format should be
        "fields/Title eq 'Cyberduck' and fields/Prod_x002e__x0020_Version eq '9.3.0' and fields/Autostage eq true"
        """
        criteria_list = []
        fields = ["ID"]
        for key in criteria:
            operand, value = criteria[key]
            internalfieldname=field_names[list_name][key]
            if value == 'true': 
                element=f"fields/{internalfieldname} eq 1"
            elif value == 'false': 
                element=f"fields/{internalfieldname} eq 0"
            else: 
                element=f"fields/{internalfieldname} eq '{value}'"
            criteria_list.append(element)
        query=' and '.join(criteria_list)
        self.output(query, verbose_level=3)
        return fields, query

    def check_autostage_jamf_content_list(self, product_name, version):
        """Check the 'Jamf Content List' list to see if the content should be auto-staged"""
        listname = "Jamf Content List"

        criteria = {}
        criteria["Self Service Content"] = ["Eq", product_name]
        criteria["Untested Version"] = ["Eq", version]
        criteria["Autostage"] = ["Eq", 'true']
        fields, query = self.build_query(criteria,listname)

        content_list_autostage_passed = False

        if self.get_filtered_list_items(list_name=listname, filter_odata=query):
            content_list_autostage_passed = True
            self.output(f"Jamf Content List for Autostage passed: {content_list_autostage_passed}")
        else:
            self.output(
                "Jamf Content List: No entry named "
                + product_name
                + " with version "
                + version
                + " with autostage set to Yes"
            )
        return content_list_autostage_passed

    def check_jamf_content_list(self, product_name, version):
        """Check the version against the untested version in the 'Jamf Content List' list"""
        listname = "Jamf Content List"

        criteria = {}
        criteria["Self Service Content"] = ["Eq", product_name]
        criteria["Untested Version"] = ["Eq", version]
        fields, query = self.build_query(criteria,listname)

        content_list_passed = False

        if self.get_filtered_list_items(list_name=listname, filter_odata=query):
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

    def check_jamf_content_test(self, product_name):
        """Check against the 'Jamf Content Test' list"""
        sp_test_listname = "Jamf Content Test"

        criteria = {}
        criteria["Self Service Content Name"] = ["Eq", product_name]
        criteria["Ready for Production"] = ["Eq", "Yes"]
        fields, query = self.build_query(criteria,sp_test_listname)

        content_test_passed = False
        if self.get_filtered_list_items(list_name=sp_test_listname, filter_odata=query):
            content_test_passed = True
            self.output(f"Jamf Content Test passed: {content_test_passed}")
        else:
            self.output(
                f"Jamf Content Test: No entry named '{product_name}' with "
                "Ready for Production 'Yes'"
            )
        return content_test_passed

    def check_jamf_test_coordination(self,   product_name):
        """Check against the 'Jamf Test Coordination' list"""
        sp_test_listname = "Jamf Test Coordination"

        criteria = {}
        criteria["Self Service Content Name"] = ["Eq", product_name]
        criteria["Status"] = ["Eq", "Done"]
        criteria["Release Completed"] = ["Eq", "No"]
        fields, query = self.build_query(criteria,sp_test_listname)

        test_coordination_passed = False
        if self.get_filtered_list_items(list_name=sp_test_listname, filter_odata=query):
            test_coordination_passed = True
            self.output(f"Jamf Test Coordination passed: {test_coordination_passed}")
        else:
            self.output(
                f"Jamf Test Coordination: No entry named '{product_name}' "
                "with Status 'Release Completed'='No'"
            )
        return test_coordination_passed

    def check_jamf_test_review(self, product_name, jss_url):
        """Check against the 'Jamf Test Review' list"""
        sp_test_listname = "Jamf Test Review"

        criteria = {}
        criteria["Self Service Content Name"] = ["Eq", product_name]
        criteria["Ready for Production"] = ["Eq", 'true']
        if "tst" in jss_url:
            criteria["Release Completed TST"] = ["Eq", 'false']
        elif "prd" in jss_url:
            criteria["Release Completed TST"] = ["Eq", "true"]
            criteria["Release Completed PRD"] = ["Eq", "No"]
        else:
            raise ProcessorError("Invalid JSS_URL supplied.")
        #criteria = {}
        #criteria["Self Service Content Name"] = ["Eq", product_name]
        #criteria["Ready for Production"] = ["Eq", 'true']
        fields, query = self.build_query(criteria,sp_test_listname)

        test_review_passed = False
        if self.get_filtered_list_items(list_name=sp_test_listname, filter_odata=query):
            test_review_passed = True
            self.output(f"Jamf Test Review passed: {test_review_passed}")
        else:
            if "tst" in jss_url:
                self.output(
                    f"Jamf Test Review: No entry named '{product_name}' with "
                    + "Release Completed TST=No and Ready for Production=Yes"
                )
            elif "prd" in jss_url:
                self.output(
                    f"Jamf Test Review: No entry named '{product_name}' with "
                    + "Release Completed PRD=No and Ready for Production=Yes"
                )
        return test_review_passed

    def main(self):
        """Do the main thing"""
        selfservice_policy_name = self.env.get("SELFSERVICE_POLICY_NAME")
        version = self.env.get("version")
        jss_url = self.env.get("JSS_URL")
        spo_url = self.env.get("SPO_URL")
        spo_user = self.env.get("SPO_USER")
        spo_pass = self.env.get("SPO_PASS")
        spo_tenant_id = self.env.get("SPO_TENANT_ID")

        sharepoint_policy_name = f"{selfservice_policy_name} (Testing) v{version}"

        ready_to_stage = False

        self.output(f"Untested Policy: {selfservice_policy_name} (Testing)")
        self.output(f"Untested SharePoint Item: {sharepoint_policy_name}")

        # verify we have the variables we need
        if not spo_url or not spo_user or not spo_pass or not spo_tenant_id:
            raise ProcessorError("Insufficient SharePoint Online credentials supplied.")

        # read sharepoint-online specific config json ; if that doesn't work, exit.
        try:
            with open( Path.home() / "Library/Preferences"  / "sharepoint-processors.config.json") as f: 
                prefs=json.load(f)
        except Exception as e:
            raise RuntimeError(f"Configuration file not found, exiting : {e}")

        global site_id
        site_id=prefs['site_id']
        global list_ids
        list_ids=prefs['list_ids']
        global field_names
        field_names=prefs['field_names']

        # authenticate against sharepoint online
        global graph_token
        graph_token=self.acquire_token(spo_user,spo_tenant_id,spo_pass)

        # check each list has the requirements met for staging
        if "tst" in jss_url:
            # tst
            if self.check_jamf_test_review(sharepoint_policy_name, jss_url):
                ready_to_stage = True
        elif "prd" in jss_url:
            # prd
            # check if autostage and test review passed
            if (
                self.check_autostage_jamf_content_list(selfservice_policy_name, version)
                and self.check_jamf_test_review(sharepoint_policy_name, jss_url)
            ):
                ready_to_stage = True
            # else check that test coordination is done and content list set as ready for production
            elif (
                self.check_jamf_content_list(selfservice_policy_name, version)
                and self.check_jamf_content_test(sharepoint_policy_name)
                and self.check_jamf_test_coordination(sharepoint_policy_name)
                and self.check_jamf_test_review(sharepoint_policy_name, jss_url)
            ):
                ready_to_stage = True
        else:
            raise ProcessorError("Invalid JSS_URL supplied.")
        self.output("Ready To Stage: {}".format(ready_to_stage))
        self.env["ready_to_stage"] = ready_to_stage


if __name__ == "__main__":
    PROCESSOR = JamfUploadSharepointStageCheck()
    PROCESSOR.execute_shell()
