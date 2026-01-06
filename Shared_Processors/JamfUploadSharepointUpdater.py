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

import urllib
import requests
import msal
import json
from pathlib import Path

from autopkglib import Processor, ProcessorError  # type: ignore

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
        "PLATFORM": {"required": False, "description": "Policy architecture."},
        "NAME": {"required": True, "description": "Product name."},
        "SELFSERVICE_POLICY_NAME": {
            "required": False,
            "description": ("Product production policy name."),
        },
        "version": {"required": True, "description": "Product version."},
    }
    output_variables = {}

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


    def get_filtered_list_items(self,list_name, filter_odata, fields_select="ID", page_size=1): # https://learn.microsoft.com/en-us/graph/api/listitem-list?view=graph-rest-1.0&tabs=http
        params = { "$top": page_size, "$filter": filter_odata, "$expand": f"fields($select={fields_select})" }
        url = f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_ids[list_name]}/items"
        headers = {"Authorization": f"Bearer {graph_token}"}
        self.output(f"querying {list_name} with {params}", verbose_level=3)
        resp = requests.get(url, headers=headers, params=params)
        if not resp.ok:
            self.output(f"GET {url} failed: {resp.status_code} {resp.text}", verbose_level=3)
            return False
        if len(resp.json()['value']) > 0: 
            return resp.json()['value'] 
        return False
    
    def update_list_item(self,list_name,itemid,data): # https://learn.microsoft.com/en-us/graph/api/listitem-update?view=graph-rest-1.0&tabs=http
        url = f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_ids[list_name]}/items/{itemid}/fields"
        headers = {"Authorization": f"Bearer {graph_token}", "Content-Type":"application/json", "Prefer":"apiversion=2.1"}
        self.output(f"Updating {list_name} item ID {itemid} with : {data}", verbose_level=3)
        resp = requests.patch(url, headers=headers, json=data)
        if not resp.ok:
            self.output(f"PATCH {url} failed: {resp.status_code} {resp.text}")
            return False
    
    def create_list_item(self,list_name,data): # https://learn.microsoft.com/en-us/graph/api/listitem-create?view=graph-rest-1.0&tabs=http
        url = f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_ids[list_name]}/items"
        headers = {"Authorization": f"Bearer {graph_token}", "Content-Type":"application/json", "Prefer":"apiversion=2.1"}
        self.output(f"Creating new item on {list_name} with : {data}", verbose_level=3)
        resp = requests.post(url, headers=headers, json=data)
        if not resp.ok:
            self.output(f"POST {url} failed: {resp.status_code} {resp.text}")
            return False
        if len(resp.json()['id']) > 0: 
            return resp.json()['id']
        return False
    
    def delete_list_item(self,list_name,itemid): # https://learn.microsoft.com/en-us/graph/api/listitem-delete?view=graph-rest-1.0&tabs=http
        url = f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_ids[list_name]}/items/{itemid}"
        headers = {"Authorization": f"Bearer {graph_token}", "Content-Type":"application/json"}
        self.output(f"Deleting {list_name} item ID {itemid}", verbose_level=3)
        resp = requests.delete(url, headers=headers)
        if not resp.ok:
            self.output(f"DELETE {url} failed: {resp.status_code} {resp.text}")
            return False 

    def build_query(self, criteria,list_name):
        """construct the query. format should be
        "fields/Title eq 'Cyberduck' and fields/Prod_x002e__x0020_Version eq '9.3.0' and fields/Autostage eq true"
        """
        criteria_list = []
        fields = ["ID"]
        for key in criteria:
            operand, value = criteria[key]
            operand=operand.lower()
            internalfieldname=field_names[list_name][key]
            if value == 'true': 
                element=f"fields/{internalfieldname} eq 1"
            elif value == 'false': 
                element=f"fields/{internalfieldname} eq 0"
            else: 
                element=f"fields/{internalfieldname} {operand} '{value}'"
            criteria_list.append(element)
        query=' and '.join(criteria_list)
        self.output(f"Built Query: {query} out of {criteria}", verbose_level=3)
        return fields, query

    def check_list(self, list_name, criteria):
        """Check an item is in a SharePoint list
        list_name        name of of the list
        search_key      key to search against
        criteria        an dictionary of criteria (key/value) to search against
        """
        fields, query = self.build_query(criteria,list_name)
        if self.get_filtered_list_items(list_name=list_name, filter_odata=query):
            return True

    def update_record(self, list_name, list_key, list_value, criteria):
        """Update a value in a SharePoint list:
        list_name        name of of the list
        list_key        key to update (friendly name)
        list_value      value to set in the key
        criteria        an dictionary of criteria (key/value) to search against
        """
        fields, query = self.build_query(criteria,list_name)

        for row in self.get_filtered_list_items(list_name=list_name, filter_odata=query):
            data = {}
            internalfieldname=field_names[list_name][list_key] #convert friendly fieldname to internal one
            self.output(f"Update {list_name} : setting {internalfieldname} to {list_value}", verbose_level=3)
            data[internalfieldname] = list_value   # for bool fields , accepts 'true' or 'false' only - capitalisation matters!
            self.output(f"updating listitem {row["id"]} in list {list_name} with {data}", verbose_level=3)
            self.update_list_item(data=data, list_name=list_name, itemid=row["id"])

    def add_record(self, list_name, list_key, list_value):
        """Create a row in a SharePoint list:
        list_name        name of of the list
        list_key        key to create (friendly name)
        list_value      value to set in the key
        """
        internalfieldname=field_names[list_name][list_key]
        new_record = {"fields": { internalfieldname: list_value }}
        self.create_list_item(list_name=list_name,data=new_record)
        self.output(f"'{list_key}' added to '{list_name}' with value '{list_value}'", verbose_level=3)

    def delete_record(self, list_name, criteria):
        """Delete an item from a SharePoint list
        listname        name of of the list
        criteria        an dictionary of criteria (key/value) to search against
        """
        fields, query = self.build_query(criteria)
        for row in self.get_filtered_list_items(list_name=list_name, filter_odata=query):
            itemid=row["ID"]
            self.delete_list_item(self,list_name,itemid=itemid)
            self.output(f"'{itemid}' deleted from '{list_name}''", verbose_level=3)

    def test_report_url(self, spo_url, policy_name): # for sharepoint online : https://ethz.sharepoint.com/sites/test-api-fuer-client-delivery/apple/Lists/Jamf_Item_Test/DispForm.aspx?ID=2526
        """Creates the Test Report URL needed in Jamf Content List"""
        params = {"Title": policy_name}
        url_encoded = urllib.parse.urlencode(params)
        list_name_url = "Jamf_Item_Test"

        test_report_url = f"{spo_url}/Lists/{list_name_url}/DispForm.aspx?{url_encoded}"
        test_report_url_dict = {"Description":"Test Report", "Url":test_report_url}
        return test_report_url_dict

        # additional header required for updates of links:  Prefer:apiversion=2.1
        ## expected data structure: { "myUrl": { "Description": "http://www.google.com", "Url": "http://www.google.com" } }

    def main(self):
        """Do the main thing"""
        policy_category = self.env.get("POLICY_CATEGORY")
        category = self.env.get("PKG_CATEGORY")
        version = self.env.get("version")
        name = self.env.get("NAME")
        final_policy_name = self.env.get("SELFSERVICE_POLICY_NAME")
        policy_language = self.env.get("LANGUAGE")
        policy_license = self.env.get("LICENSE")
        major_version = self.env.get("MAJOR_VERSION")
        platform = self.env.get("PLATFORM")
        executable_command = self.env.get("SP_EXECUTABLE_COMMAND")
        process_name = self.env.get("SP_PROCESS_NAME")
        jss_url = self.env.get("JSS_URL")
        spo_url = self.env.get("SPO_URL")
        spo_user = self.env.get("SPO_USER")
        spo_pass = self.env.get("SPO_PASS")
        spo_tenant_id = self.env.get("SPO_TENANT_ID")

        # verify we have the variables we need
        if not spo_url or not spo_user or not spo_pass or not spo_tenant_id:
            raise ProcessorError("Insufficient SharePoint Online credentials supplied.")

        # read sharepoint-online specific config json ; if that doesn't work, exit.
        # this json contains site id, list ids, and internal field names of lists so they don't have to be rediscovered every time.
        # expected format : { "site_id":"something", "list_ids": {"Jamf Content List": "id", "Jamf Content Test": "id", "Jamf Test Review": "id", "Jamf Test Coordination": "id" }, "field_names": {"Jamf Content List":{"Self Service Content": "Title",... }, "Jamf Content Test":{"Self Service Content": "Title",...}, ... }
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

        # section for untested recipes (PRD server only)
        if not final_policy_name:
            if "prd" in jss_url:
                final_policy_name = name
                if major_version:
                    final_policy_name = final_policy_name + " " + major_version
                if policy_language:
                    final_policy_name = final_policy_name + " " + policy_language
                if policy_license:
                    final_policy_name = final_policy_name + " " + policy_license
                if platform:
                    final_policy_name = final_policy_name + " " + platform

                policy_name = f"{final_policy_name} (Testing)"
                self_service_policy_name = f"{final_policy_name} (Testing) v{version}"

                self.output( "UNTESTED recipe type: "
                    "Sending updates to SharePoint based on Policy Name "
                    + final_policy_name
                )

                self.output("Name: %s" % name)
                self.output("Title: %s" % final_policy_name)
                self.output("Policy: %s" % policy_name)
                self.output("Version: %s" % version)
                self.output("SharePoint item: %s" % self_service_policy_name)
                self.output("Production Category: %s" % category)
                self.output("Current Category: %s" % policy_category)

                # Now write to the Jamf Content List
                # First, check if there is an existing entry for this policy
                criteria = {}
                criteria["Self Service Content"] = ["Eq", final_policy_name]

                app_in_content_list = self.check_list(
                     "Jamf Content List", criteria
                )

                # if not, create the entry
                if not app_in_content_list:
                    self.output(
                        "Jamf Content List: Adding new entry for " + final_policy_name
                    )
                    self.add_record(
                        "Jamf Content List",
                        "Self Service Content",
                        final_policy_name,
                    )
                else:
                    self.output(
                        "Jamf Content List: Updating existing entry for "
                        + final_policy_name
                    )
                # now update the other keys in the entry
                self.output(
                    "Jamf Content List: Setting 'Untested Version' "
                    + version
                    + " for "
                    + final_policy_name
                )
                self.update_record(
                    "Jamf Content List",
                    "Untested Version",
                    version,
                    criteria,
                )
                self.update_record(
                    "Jamf Content List",
                    "Category",
                    category,
                    criteria,
                )
                self.update_record(
                    "Jamf Content List",
                    "Content Type",
                    "Application",
                    criteria,
                )

                # Now write to Jamf Test Coordination list
                # First, check if the content is set to Autostage in the content list.
                criteria = {}
                criteria["Self Service Content"] = ["Eq", final_policy_name]
                criteria["Autostage"] = ["Eq", "true"]

                is_app_autostage = self.check_list( "Jamf Content List", criteria)
                if is_app_autostage:
                    self.output(
                        f"Jamf Content List: {final_policy_name} is set to Autostage"
                    )
                else:
                    self.output(
                        f"Jamf Content List: {final_policy_name} is not set to Autostage"
                    )

                # Now, check if there is an existing entry for this policy (including version)
                # which has been released
                criteria = {}
                criteria["Self Service Content Name"] = ["Eq", self_service_policy_name]
                criteria["Release Completed"] = ["Eq", "true"]

                exact_policy_in_test_coordination_and_released = self.check_list(
                     "Jamf Test Coordination", criteria
                )

                # if so, set back to release completed = No
                if exact_policy_in_test_coordination_and_released:
                    self.output(
                        "Jamf Test Coordination: Setting 'Release Completed'='No' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Coordination",
                        "Release Completed",
                        "false",
                        criteria,
                    )
                # Now check if there is an existing entry for this policy (including version)
                # if so, existing tests are no longer valid, so ensure to set the entry
                # to 'Needs review' if some tests were already done
                criteria = {}
                criteria["Self Service Content Name"] = ["Eq", self_service_policy_name]

                exact_policy_in_test_coordination = self.check_list(
                     "Jamf Test Coordination", criteria
                )

                if exact_policy_in_test_coordination:
                    if is_app_autostage:
                        # set Status to Autostage on the existing entry
                        criteria = {}
                        criteria["Self Service Content Name"] = [
                            "Eq",
                            self_service_policy_name,
                        ]
                        criteria["Status"] = ["Neq", "Autostage"]

                        self.output(
                            "Jamf Test Coordination: Setting 'Status'='Autostage' for "
                            + self_service_policy_name
                        )
                        self.update_record(
                            "Jamf Test Coordination",
                            "Status",
                            "Autostage",
                            criteria,
                        )
                    else:
                        # reset Status if any work had already been done on the existing entry
                        check_criteria = [
                            "In progress",
                            "Done",
                            "Deferred",
                            "Waiting for other test manager",
                        ]
                        for check in check_criteria:
                            criteria = {}
                            criteria["Self Service Content Name"] = [
                                "Eq",
                                self_service_policy_name,
                            ]
                            criteria["Release Completed"] = ["Eq", "false"]
                            criteria["Status"] = ["Eq", check]
                            app_in_test_coordination_tested_but_not_released = (
                                self.check_list(
                                     "Jamf Test Coordination", criteria
                                )
                            )
                            if app_in_test_coordination_tested_but_not_released:
                                self.output(
                                    "Jamf Test Coordination: Setting 'Status'='Needs review' for "
                                    + self_service_policy_name
                                )
                                self.update_record(
                                    "Jamf Test Coordination",
                                    "Status",
                                    "Needs review",
                                    criteria,
                                )
                else:
                    # check if there is an entry with the same final policy name that is
                    # not release completed
                    criteria = {}
                    criteria["Final Content Name"] = ["Eq", final_policy_name]
                    criteria["Release Completed"] = ["Eq", "false"]
                    criteria["Status"] = ["Neq", "Obsolete"]

                    app_in_test_coordination_not_released = self.check_list(
                        "Jamf Test Coordination",
                        criteria,
                    )
                    if app_in_test_coordination_not_released:
                        self.output(
                            "Jamf Test Coordination: Updating existing unreleased "
                            "entry for " + final_policy_name
                        )
                        self.output(
                            "Jamf Test Coordination: Setting 'Status'='Obsolete' for "
                            + final_policy_name
                        )
                        self.update_record(
                            "Jamf Test Coordination",
                            "Status",
                            "Obsolete",
                            criteria,
                        )

                    # now create a new entry
                    self.output(
                        "Jamf Test Coordination: Adding record for "
                        + self_service_policy_name
                    )
                    self.add_record(
                        "Jamf Test Coordination",
                        "Self Service Content Name",
                        self_service_policy_name,
                    )

                    criteria = {}
                    criteria["Self Service Content Name"] = [
                        "Eq",
                        self_service_policy_name,
                    ]

                    self.output(
                        "Jamf Test Coordination: Setting 'Final Content Name' "
                        + final_policy_name
                        + " for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Coordination",
                        "Final Content Name",
                        final_policy_name,
                        criteria,
                    )
                    if is_app_autostage:
                        self.output(
                            "Jamf Test Coordination: Setting 'Status'='Autostage' for "
                            + self_service_policy_name
                        )
                        self.update_record(
                            "Jamf Test Coordination",
                            "Status",
                            "Autostage",
                            criteria,
                        )

                # Now write to Jamf Test Review list
                # First, check if there is an existing entry for this policy (including version)
                criteria = {}
                criteria["Self Service Content Name"] = ["Eq", self_service_policy_name]

                exact_policy_in_test_review = self.check_list(
                     "Jamf Test Review", criteria
                )

                # if so, existing tests are no longer valid, so set the entry to
                # Release Completed='False' and Ready for Production="No"
                if exact_policy_in_test_review:
                    self.output(
                        "Jamf Test Review: Updating existing entry for "
                        + self_service_policy_name
                    )
                    self.output(
                        "Jamf Test Review: Setting 'Release Completed TST'='No' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Review",
                        "Release Completed TST",
                        "false",
                        criteria,
                    )
                    self.output(
                        "Jamf Test Review: Setting 'Release Completed PRD'='No' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Review",
                        "Release Completed PRD",
                        "No",
                        criteria,
                    )
                    self.output(
                        "Jamf Test Review: Setting 'Ready for Production'='No' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Review",
                        "Ready for Production",
                        "false",
                        criteria,
                    )
                    self.output(
                        "Jamf Test Review: Setting 'ApplicationName'='applicaton_name' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Review",
                        "Executable_Command",
                        executable_command,
                        criteria,
                    )
                    self.output(
                        "Jamf Test Review: Setting 'Process_Name'='process_name' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Review",
                        "Process_Name",
                        process_name,
                        criteria,
                    )
                else:
                    # check if there is an entry with the same final policy name that is not
                    # release completed in TST or PRD
                    criteria = {}
                    criteria["Final Content Name"] = ["Eq", final_policy_name]
                    criteria["Release Completed TST"] = ["Eq", "false"]

                    app_in_test_review_not_released = self.check_list(
                        "Jamf Test Review",
                        criteria,
                    )

                    # if not release completed in TST, delete the record
                    if app_in_test_review_not_released:
                        self.output(
                            "Jamf Test Review: Deleting existing unreleased entry for "
                            + final_policy_name
                        )
                        self.delete_record(
                            "Jamf Test Review",
                            criteria,
                        )
                    # if not release completed in PRD, set the record to skipped
                    else:
                        criteria = {}
                        criteria["Final Content Name"] = ["Eq", final_policy_name]
                        criteria["Release Completed PRD"] = ["Eq", "No"]

                        app_in_test_review_not_released_to_prd = self.check_list(
                            "Jamf Test Review",
                            criteria,
                        )
                        if app_in_test_review_not_released_to_prd:
                            self.output(
                                "Jamf Test Review: Setting existing unreleased (PRD) entry "
                                f"for '{final_policy_name}' to 'Skipped'"
                            )
                            self.update_record(
                                "Jamf Test Review",
                                "Release Completed PRD",
                                "Skipped",
                                criteria,
                            )

                    # now create a new entry
                    self.output(
                        "Jamf Test Review: Adding record for" + self_service_policy_name
                    )
                    self.add_record(
                        "Jamf Test Review",
                        "Self Service Content Name",
                        self_service_policy_name,
                    )
                    criteria = {}
                    criteria["Self Service Content Name"] = [
                        "Eq",
                        self_service_policy_name,
                    ]
                    self.output(
                        "Jamf Test Review: Setting 'Final Content Name' "
                        + final_policy_name
                        + " for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Review",
                        "Final Content Name",
                        final_policy_name,
                        criteria,
                    )
                    self.output(
                        "Jamf Test Review: Setting 'Executable_Command'='executable_command' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Review",
                        "Executable_Command",
                        executable_command,
                        criteria,
                    )
                    self.output(
                        "Jamf Test Review: Setting 'Process_Name'='process_name' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Review",
                        "Process_Name",
                        process_name,
                        criteria,
                    )

        # section for prod recipes
        else:
            self_service_policy_name = f"{final_policy_name} (Testing) v{version}"

            self.output("Name: " + name)
            self.output("Policy: " + final_policy_name)
            self.output("Version: " + version)
            self.output("SharePoint item: " + self_service_policy_name)
            self.output("Production Category: " + category)
            self.output("Current Category: " + policy_category)

            self.output("PROD recipe type: Sending staging instructions to SharePoint")

            # Now write to Jamf Test Coordination list
            # Here we need to set Release Completed to True

            # First, check if there is an existing entry for this policy (including version)
            criteria = {}
            criteria["Self Service Content Name"] = ["Eq", self_service_policy_name]

            exact_policy_in_test_coordination = self.check_list("Jamf Test Coordination", criteria)

            # if not, we should create one
            if exact_policy_in_test_coordination:
                self.output(
                    "Jamf Test Coordination: Updating existing entry for "
                    + self_service_policy_name
                )
            else:
                self.output(
                    "Jamf Test Coordination: Adding record for "
                    + self_service_policy_name
                )
                self.add_record(
                    "Jamf Test Coordination",
                    "Self Service Content Name",
                    self_service_policy_name,
                )
                self.output(
                    "Jamf Test Coordination: Setting 'Final Content Name' "
                    + final_policy_name
                    + " for "
                    + self_service_policy_name
                )
                self.update_record(
                    "Jamf Test Coordination",
                    "Final Content Name",
                    final_policy_name,
                    criteria,
                )

            # set Jamf Test Coordination to "Release Completed"="Yes" only from PRD
            if "prd" in jss_url:
                # First, check if the content is set to Autostage in the content list.
                autostage_criteria = {}
                autostage_criteria["Self Service Content"] = ["Eq", final_policy_name]
                autostage_criteria["Autostage"] = ["Eq", "true"]

                is_app_autostage = self.check_list(
                     "Jamf Content List", autostage_criteria
                )
                if is_app_autostage:
                    self.output(
                        f"Jamf Content List: {final_policy_name} is set to Autostage"
                    )
                else:
                    self.output(
                        f"Jamf Content List: {final_policy_name} is not set to Autostage"
                    )
                # now write the changes to Test Coordination
                self.output(
                    "Jamf Test Coordination: Setting 'Release Completed'='Yes' for "
                    + self_service_policy_name
                )
                self.update_record(
                    "Jamf Test Coordination",
                    "Release Completed",
                    "true",
                    criteria,
                )
                if is_app_autostage:
                    self.output(
                        "Jamf Test Coordination: Setting 'Status'='Autostage' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Coordination",
                        "Status",
                        "Autostage",
                        criteria,
                    )
                else:
                    self.output(
                        "Jamf Test Coordination: Setting 'Status'='Done' for "
                        + self_service_policy_name
                    )
                    self.update_record(
                        "Jamf Test Coordination",
                        "Status",
                        "Done",
                        criteria,
                    )

            # Now write to Jamf Test Review list
            # Here we need to set Release Completed to True
            # First, check if there is an existing entry for this policy (including version)
            criteria = {}
            criteria["Self Service Content Name"] = ["Eq", self_service_policy_name]
            exact_policy_in_test_review = self.check_list(
                 "Jamf Test Review", criteria
            )

            # if not, we should create one
            if exact_policy_in_test_review:
                self.output(
                    "Jamf Test Review: Updating existing entry for "
                    + self_service_policy_name
                )
            else:
                self.output(
                    "Jamf Test Review: Adding record for " + self_service_policy_name
                )
                self.add_record(
                    "Jamf Test Review",
                    "Self Service Content Name",
                    self_service_policy_name,
                )
                self.output(
                    "Jamf Test Review: Setting 'Final Content Name' "
                    + final_policy_name
                    + " for "
                    + self_service_policy_name
                )
                self.update_record(
                    "Jamf Test Review",
                    "Final Content Name",
                    final_policy_name,
                    criteria,
                )
            # set Jamf Test Review to "Release Completed" only from TST
            if "tst" in jss_url:
                self.output(
                    "Jamf Test Review: Setting 'Release Completed TST'='Yes' for "
                    + self_service_policy_name
                )
                self.update_record(
                    "Jamf Test Review",
                    "Release Completed TST",
                    "true",
                    criteria,
                )
                # Set ready for production to Yes in case we are forcing the staging
                self.output(
                    "Jamf Test Review: Setting 'Ready for Production'='Yes' for "
                    + self_service_policy_name
                )
                self.update_record(
                    "Jamf Test Review",
                    "Ready for Production",
                    "true",
                    criteria,
                )
            # set Jamf Test Review to "Release Completed PRD"="Yes" only from PRD
            elif "prd" in jss_url:
                self.output(
                    "Jamf Test Review: Setting 'Release Completed PRD'='Yes' for "
                    + self_service_policy_name
                )
                self.update_record(
                    "Jamf Test Review",
                    "Release Completed PRD",
                    "Yes",
                    criteria,
                )

            # Now write to the Jamf Content List (PRD only)
            # Here we need to clear the untested version, change the prod version, and
            # add the test report URL
            # First, check if there is an existing entry for this policy
            if "prd" in jss_url:
                criteria = {}
                criteria["Self Service Content"] = ["Eq", final_policy_name]
                app_in_content_list = self.check_list( "Jamf Content List", criteria )

                # if not, create the entry
                if not app_in_content_list:
                    self.output(
                        "Jamf Content List: Adding new entry for " + final_policy_name
                    )
                    self.add_record(
                        "Jamf Content List",
                        "Self Service Content",
                        final_policy_name,
                    )
                else:
                    self.output(
                        "Jamf Content List: Updating existing entry for "
                        + final_policy_name
                    )
                # now update the other keys in the entry
                self.output(
                    "Jamf Content List: Clearing 'Untested Version' for "
                    + final_policy_name
                )
                self.update_record(
                    "Jamf Content List",
                    "Untested Version",
                    "",
                    criteria,
                )
                self.output(
                    "Jamf Content List: Setting 'Prod. Version'='"
                    + version
                    + "' for "
                    + final_policy_name
                )
                self.update_record(
                     "Jamf Content List", "Prod. Version", version, criteria
                )
                # Test Report requires special work as it is a dictionary of title and url
                self.output(
                    "Jamf Content List: Setting 'Test Report' for " + final_policy_name
                )
                self.update_record(
                    "Jamf Content List",
                    "Test Report",
                    self.test_report_url(spo_url, self_service_policy_name),
                    #+ ", Test Report",
                    criteria,
                )

if __name__ == "__main__":
    PROCESSOR = JamfUploadSharepointUpdater()
    PROCESSOR.execute_shell()
