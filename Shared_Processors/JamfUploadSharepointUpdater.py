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


from __future__ import absolute_import

import ssl

import urllib
from sharepoint import SharePointSite
from ntlm3 import HTTPNtlmAuthHandler
from autopkglib import Processor  # type: ignore

ssl._create_default_https_context = ssl._create_unverified_context
__all__ = ["JamfUploadSharepointUpdater"]


class JamfUploadSharepointUpdater(Processor):
    description = (
        "Performs actions on a SharePoint site based on output of a JSSImporter run."
    )
    input_variables = {
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

    @staticmethod
    def connect_sharepoint(url, user, password):
        """make a connection to SharePoint"""
        pass_man = urllib.request.HTTPPasswordMgrWithDefaultRealm()
        pass_man.add_password(None, url, user, password)
        auth_ntlm = HTTPNtlmAuthHandler.HTTPNtlmAuthHandler(pass_man)
        opener = urllib.request.build_opener(auth_ntlm)
        urllib.request.install_opener(opener)
        site = SharePointSite(url, opener)
        return site

    def check_list(self, site, sp_listname, sp_list_criterion, sp_list_criterion_value):
        """Check an item is in a SharePoint list

        site:                       SharePoint site where the list is situated
        sp_listname:                name of of the list
        sp_list_criterion:          key to search against (normally Title)
        sp_list_criterion_value:    value of key to match
        """
        sp_list = site.lists[sp_listname]
        # sp_product_in_list = False
        for row in sp_list.rows:
            sp_policy_name = getattr(row, sp_list_criterion)
            if sp_policy_name == sp_list_criterion_value:
                return row

    def update_record(
        self,
        site,
        sp_listname,
        sp_list_key,
        sp_list_value,
        sp_list_criterion,
        sp_list_criterion_value,
    ):
        """Update a value in a SharePoint list:

        site:                       SharePoint site where the list is situated
        sp_listname:                name of of the list
        sp_list_key:                key to update
        sp_list_value:              value to set in the key
        sp_list_criterion:          key to search against (normally Title)
        sp_list_criterion_value:    value of key to match
        """
        sp_list = site.lists[sp_listname]
        for row in sp_list.rows:
            # update sp_list_key with value sp_list_value
            # where sp_list_criterion = sp_list_criterion_value
            if sp_list_criterion_value == getattr(row, sp_list_criterion):
                existing_value = getattr(row, sp_list_key)
                setattr(row, sp_list_key, sp_list_value)
                self.output(
                    "'%s' - '%s' updated from '%s' to '%s'"
                    % (
                        sp_list_criterion_value,
                        sp_list_key,
                        existing_value,
                        sp_list_value,
                    )
                )
                sp_list.save()

    def add_record(self, site, sp_listname, sp_list_key, sp_list_value):
        """Update a value in a SharePoint list:

        site:                       SharePoint site where the list is situated
        sp_listname:                name of of the list
        sp_list_key:                key to update
        sp_list_value:              value to set in the key
        """
        sp_list = site.lists[sp_listname]
        # add record to list
        sp_new_record = {}
        sp_new_record[sp_list_key] = sp_list_value
        sp_list.append(sp_new_record)
        sp_list.save()
        self.output("'%s' added with value '%s'" % (sp_list_key, sp_list_value))

    def delete_record(
        self, site, sp_listname, sp_list_criterion, sp_list_criterion_value
    ):
        """Delete an item from a SharePoint list

        site:                       SharePoint site where the list is situated
        sp_listname:                name of of the list
        sp_list_criterion:          key to search against (normally Title)
        sp_list_criterion_value:    value of key to match
        """
        sp_list = site.lists[sp_listname]
        for row in sp_list.rows:
            # update sp_list_key with value sp_list_value
            # where sp_list_criterion = sp_list_criterion_value
            if sp_list_criterion_value == getattr(row, sp_list_criterion):
                existing_value = getattr(row, sp_list_criterion)
                row.delete()
                sp_list.save()
                self.output(
                    "Item '%s' with value '%s' deleted"
                    % (sp_list_criterion, existing_value)
                )

    def test_report_url(self, sp_url, policy_name):
        """Creates the Test Report URL needed in Jamf Content List"""
        params = {"Title": policy_name}
        url_encoded = urllib.parse.urlencode(params)
        list_name_url = "Jamf_Item_Test"
        test_report_url = "%s/Lists/%s/DispForm.aspx?%s" % (
            sp_url,
            list_name_url,
            url_encoded,
        )
        return test_report_url

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
        sp_url = self.env.get("SP_URL")
        sp_user = self.env.get("SP_USER")
        sp_pass = self.env.get("SP_PASS")

        # section for untested recipes
        if not selfservice_policy_name:

            selfservice_policy_name = name
            if major_version:
                selfservice_policy_name = selfservice_policy_name + " " + major_version
            if policy_language:
                selfservice_policy_name = (
                    selfservice_policy_name + " " + policy_language
                )
            if policy_license:
                selfservice_policy_name = selfservice_policy_name + " " + policy_license

            policy_name = f"{selfservice_policy_name} (Testing)"
            sharepoint_policy_name = f"{selfservice_policy_name} (Testing) v{version}"

            self.output(
                "UNTESTED recipe type: "
                f"Sending updates to SharePoint based on Policy Name {selfservice_policy_name}"
            )

            self.output("Name: %s" % name)
            self.output("Title: %s" % selfservice_policy_name)
            self.output("Policy: %s" % policy_name)
            self.output("Version: %s" % version)
            self.output("SharePoint item: %s" % sharepoint_policy_name)
            self.output("Production Category: %s" % category)
            self.output("Current Category: %s" % policy_category)

            # connect to the sharepoint site
            site = self.connect_sharepoint(sp_url, sp_user, sp_pass)

            # Now write to Jamf Test Coordination list
            # First, check if there is an existing entry for this policy (including version)
            exact_policy_in_test_coordination = self.check_list(
                site, "Jamf Test Coordination", "Title", sharepoint_policy_name
            )

            # if so, existing tests are no longer valid, so set the entry to 'Needs review'
            if exact_policy_in_test_coordination:
                self.output(
                    "Jamf Test Coordination: Ensuring existing '%s' entry is not"
                    "set as Release Completed" % sharepoint_policy_name
                )
                self.update_record(
                    site,
                    "Jamf Test Coordination",
                    "Release_x0020_Completed",
                    None,
                    "Title",
                    sharepoint_policy_name,
                )
                if exact_policy_in_test_coordination.Status not in {
                    "Not assigned",
                    "Not started",
                }:
                    self.output(
                        "Jamf Test Coordination: Updating existing '%s' as Needs review"
                        % sharepoint_policy_name
                    )
                    self.update_record(
                        site,
                        "Jamf Test Coordination",
                        "Status",
                        "Needs review",
                        "Title",
                        sharepoint_policy_name,
                    )
            else:
                # check if there is an entry with the same final policy name that is
                # not release completed
                app_in_test_coordination = self.check_list(
                    site,
                    "Jamf Test Coordination",
                    "Final_x0020_Item_x0020_Name",
                    selfservice_policy_name,
                )

                # if not released completed, update the entry and set it to obsolete.
                if (
                    app_in_test_coordination
                    and app_in_test_coordination.Release_x0020_Completed is not True
                ):
                    self.output(
                        "Jamf Test Coordination: Updating existing unreleased "
                        "entry for '%s'" % selfservice_policy_name
                    )
                    self.update_record(
                        site,
                        "Jamf Test Coordination",
                        "Release_x0020_Completed",
                        None,
                        "Final_x0020_Item_x0020_Name",
                        selfservice_policy_name,
                    )
                    self.update_record(
                        site,
                        "Jamf Test Coordination",
                        "Status",
                        "Obsolete",
                        "Final_x0020_Item_x0020_Name",
                        selfservice_policy_name,
                    )

                # now create a new entry
                self.output(
                    "Jamf Test Coordination: Adding record for '%s'"
                    % sharepoint_policy_name
                )
                self.add_record(
                    site, "Jamf Test Coordination", "Title", sharepoint_policy_name
                )
                self.update_record(
                    site,
                    "Jamf Test Coordination",
                    "Final_x0020_Item_x0020_Name",
                    selfservice_policy_name,
                    "Title",
                    sharepoint_policy_name,
                )

            # Now write to Jamf Test Review list
            # First, check if there is an existing entry for this policy (including version)
            exact_policy_in_test_review = self.check_list(
                site, "Jamf Test Review", "Title", sharepoint_policy_name
            )

            # if so, existing tests are no longer valid, so set the entry to
            # Release Completed=False'
            if exact_policy_in_test_review:
                self.output(
                    "Jamf Test Review: Updating existing entry for '%s'"
                    % sharepoint_policy_name
                )
                self.update_record(
                    site,
                    "Jamf Test Review",
                    "Release_x0020_Completed",
                    None,
                    "Title",
                    sharepoint_policy_name,
                )
            else:
                # check if there is an entry with the same final policy name that is not
                # release completed
                app_in_test_review = self.check_list(
                    site,
                    "Jamf Test Review",
                    "Final_x0020_Content_x0020_Name",
                    selfservice_policy_name,
                )
                # if so, delete the record
                if app_in_test_review:
                    self.output(
                        "Jamf Test Review: Deleting existing unreleased entry for '%s'"
                        % selfservice_policy_name
                    )
                    self.delete_record(
                        site,
                        "Jamf Test Review",
                        "Final_x0020_Content_x0020_Name",
                        selfservice_policy_name,
                    )

                # now create a new entry
                self.output(
                    "Jamf Test Review: Adding record for '%s'" % sharepoint_policy_name
                )
                self.add_record(
                    site, "Jamf Test Review", "Title", sharepoint_policy_name
                )
                self.update_record(
                    site,
                    "Jamf Test Review",
                    "Final_x0020_Content_x0020_Name",
                    selfservice_policy_name,
                    "Title",
                    sharepoint_policy_name,
                )
                self.update_record(
                    site,
                    "Jamf Test Review",
                    "Release_x0020_Completed",
                    None,
                    "Title",
                    sharepoint_policy_name,
                )

            # Now write to the Jamf Content List
            # First, check if there is an existing entry for this policy
            app_in_content_list = self.check_list(
                site, "Jamf Content List", "Title", selfservice_policy_name
            )

            # if not, create the entry
            if not app_in_content_list:
                self.output(
                    "Jamf Content List: Adding new entry for '%s'"
                    % selfservice_policy_name
                )
                self.add_record(
                    site, "Jamf Content List", "Title", selfservice_policy_name
                )
            else:
                self.output(
                    "Jamf Content List: Updating existing entry for '%s'"
                    % selfservice_policy_name
                )

            # now update the other keys in the entry
            self.update_record(
                site,
                "Jamf Content List",
                "Untested_x0020_Version",
                version,
                "Title",
                selfservice_policy_name,
            )
            self.update_record(
                site,
                "Jamf Content List",
                "Category",
                category,
                "Title",
                selfservice_policy_name,
            )
            self.update_record(
                site,
                "Jamf Content List",
                "Name_x0020_of_x0020_the_x0020_Po",
                "Application",
                "Title",
                selfservice_policy_name,
            )

        # section for prod recipes
        else:
            sharepoint_policy_name = f"{selfservice_policy_name} (Testing) v{version}"

            self.output("Name: %s" % name)
            self.output("Policy: %s" % selfservice_policy_name)
            self.output("Version: %s" % version)
            self.output("SharePoint item: %s" % sharepoint_policy_name)
            self.output("Production Category: %s" % category)
            self.output("Current Category: %s" % policy_category)

            self.output("PROD recipe type: Sending staging instructions to SharePoint")
            # connect to the sharepoint site
            site = self.connect_sharepoint(sp_url, sp_user, sp_pass)

            # Now write to Jamf Test Coordination list
            # Here we need to set Release Completed to True

            # First, check if there is an existing entry for this policy (including version)
            exact_policy_in_test_coordination = self.check_list(
                site, "Jamf Test Coordination", "Title", sharepoint_policy_name
            )

            # if not, we should create one
            if exact_policy_in_test_coordination:
                self.output(
                    "Jamf Test Coordination: Updating existing entry for '%s'"
                    % sharepoint_policy_name
                )
            else:
                self.output(
                    "Jamf Test Coordination: Adding record for '%s'"
                    % sharepoint_policy_name
                )
                self.add_record(
                    site, "Jamf Test Coordination", "Title", sharepoint_policy_name
                )
                self.update_record(
                    site,
                    "Jamf Test Coordination",
                    "Final_x0020_Item_x0020_Name",
                    selfservice_policy_name,
                    "Title",
                    sharepoint_policy_name,
                )
            self.update_record(
                site,
                "Jamf Test Coordination",
                "Release_x0020_Completed",
                True,
                "Title",
                sharepoint_policy_name,
            )
            self.update_record(
                site,
                "Jamf Test Coordination",
                "Status",
                "Done",
                "Title",
                sharepoint_policy_name,
            )

            # Now write to Jamf Test Review list
            # Here we need to set Release Completed to True
            # First, check if there is an existing entry for this policy (including version)
            exact_policy_in_test_review = self.check_list(
                site, "Jamf Test Review", "Title", sharepoint_policy_name
            )

            # if not, we should create one
            if exact_policy_in_test_review:
                self.output(
                    "Jamf Test Review: Updating existing entry for '%s'"
                    % sharepoint_policy_name
                )
            else:
                self.output(
                    "Jamf Test Review: Adding record for '%s'" % sharepoint_policy_name
                )
                self.add_record(
                    site, "Jamf Test Review", "Title", sharepoint_policy_name
                )
                self.update_record(
                    site,
                    "Jamf Test Review",
                    "Final_x0020_Content_x0020_Name",
                    selfservice_policy_name,
                    "Title",
                    sharepoint_policy_name,
                )
            self.update_record(
                site,
                "Jamf Test Review",
                "Release_x0020_Completed",
                True,
                "Title",
                sharepoint_policy_name,
            )
            self.update_record(
                site,
                "Jamf Test Review",
                "Ready_x0020_for_x0020_Production",
                True,
                "Title",
                sharepoint_policy_name,
            )

            # Now write to the Jamf Content List
            # Here we need to clear the untested version, change the prod version, and
            # add the test report URL
            # First, check if there is an existing entry for this policy
            app_in_content_list = self.check_list(
                site, "Jamf Content List", "Title", selfservice_policy_name
            )

            # if not, create the entry
            if not app_in_content_list:
                self.output(
                    "Jamf Content List: Adding new entry for '%s'"
                    % selfservice_policy_name
                )
                self.add_record(
                    site, "Jamf Content List", "Title", selfservice_policy_name
                )
            else:
                self.output(
                    "Jamf Content List: Updating existing entry for '%s'"
                    % selfservice_policy_name
                )

            # now update the other keys in the entry
            self.update_record(
                site,
                "Jamf Content List",
                "Untested_x0020_Version",
                "",
                "Title",
                selfservice_policy_name,
            )
            self.update_record(
                site,
                "Jamf Content List",
                "Prod_x002e__x0020_Version",
                version,
                "Title",
                selfservice_policy_name,
            )
            # Test Report requires special work as it is a dictionary of title and url
            self.update_record(
                site,
                "Jamf Content List",
                "Test_x0020_Report",
                {
                    "text": "Test Report",
                    "href": self.test_report_url(sp_url, sharepoint_policy_name),
                },
                "Title",
                selfservice_policy_name,
            )


if __name__ == "__main__":
    PROCESSOR = JamfUploadSharepointUpdater()
    PROCESSOR.execute_shell()
