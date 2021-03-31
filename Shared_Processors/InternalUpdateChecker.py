#!/usr/local/autopkg/python
#
# 2017 Graham R Pugh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""See docstring for InternalUpdateChecker class"""

from __future__ import absolute_import
import os
import glob
import csv
from autopkglib import (
    APLooseVersion,
    Processor,
    ProcessorError,
)  # pylint: disable=import-error

__all__ = ["InternalUpdateChecker"]


class InternalUpdateChecker(Processor):
    """Provides file path to the highest version number."""

    input_variables = {
        "list_name": {
            "required": True,
            "description": ("Name of the product as displayed in the ITShop " "List."),
        },
        "List_language": {
            "required": True,
            "description": "Language of the product as displayed in the ITShop.",
        },
        "list_source": {
            "required": True,
            "description": (
                "Path to file containing list of IT Shop available " "items."
            ),
        },
        "list_delimiter": {
            "required": False,
            "description": ("Character used in the file to separate columns."),
            "default": ",",
        },
        "title_col": {
            "required": True,
            "description": (
                "Column containing the software title, where the " "first column is 0."
            ),
        },
        "lang_col": {
            "required": True,
            "description": (
                "Column containing the software language, where "
                "the first column is 0."
            ),
        },
        "version_col": {
            "required": True,
            "description": (
                "Column containing the software version, where the "
                "first column is 0."
            ),
        },
        "path_col": {
            "required": True,
            "description": (
                "Column containing the path to the software "
                "installer, where the first column is 0."
            ),
        },
        "license_col": {
            "required": True,
            "description": (
                "Column containing the path to the software "
                "license key, where the first column is 0."
            ),
        },
        "license_file_col": {
            "required": True,
            "description": (
                "Column containing the path to the software "
                "license file, where the first column is 0."
            ),
        },
        "mounted_repo": {
            "required": True,
            "description": ("Path to repo containing IT Shop available " "items."),
        },
        "RECIPE_CACHE_DIR": {
            "required": True,
            "description": ("AutoPkg recipe cache directory."),
        },
        "list_major_version": {
            "required": False,
            "description": ("Restrict to a major version if specified."),
        },
        "list_filter": {
            "required": False,
            "description": ("Filter DMGs by an additional string if specified."),
            "default": "",
        },
    }

    output_variables = {
        "version": {
            "description": (
                "The highest folder name according to " "parse_version logic."
            ),
        },
        "latest_file": {
            "description": (
                "The filename of the highest version according to "
                "parse_version logic."
            ),
        },
        "file_exists": {
            "description": (
                "Boolean to show whether the latest version is "
                "already present in the AutoPkg Cache"
            ),
        },
        "file_path": {
            "description": ("Path to the package at the source " "including filename"),
        },
        "local_path": {
            "description": (
                "Path to the package in the AutoPkg Cache " "including filename"
            ),
        },
        "file_dir": {
            "description": (
                "Path to the package in thesource " "not including filename"
            ),
        },
        "license_key": {"description": ("The license key in the list_source")},
        "license_file_path": {
            "description": ("The filename of the license file in the " "list_source"),
        },
    }

    description = __doc__

    @staticmethod
    def get_list(product_list_file, file_delimiter):
        """Convert the product list file to a list-of-lists."""
        with open(product_list_file, "r") as csv_file:
            reader = csv.reader(csv_file, delimiter=file_delimiter, quotechar='"')
            product_list = list(reader)

        return product_list

    @staticmethod
    def get_product_list(
        product_list,
        product_name,
        product_language,
        title_column,
        version_column,
        language_column,
        path_column,
        license_column,
        license_file_column,
    ):
        """Read the product list-of-lists and grab the items with the correct name and language."""
        product_matches_list = []
        for row in product_list:
            product_name_in_list = row[title_column]
            product_version_in_list = row[version_column]
            product_language_in_list = row[language_column]
            product_path_in_list = row[path_column]
            product_license_key_in_list = row[license_column]
            product_license_file_in_list = row[license_file_column]
            if (
                product_name_in_list == product_name
                and product_language_in_list == product_language
            ):
                new_item = [
                    product_version_in_list,
                    product_path_in_list,
                    product_license_key_in_list,
                    product_license_file_in_list,
                ]
                try:
                    product_matches_list.append(new_item)
                except NameError:
                    product_matches_list = [new_item]
        return product_matches_list

    def get_latest_version(self, product_matches_list, major_version=""):
        """Find the latest version in the list."""
        latest_version = "0"
        latest_license = ""
        latest_license_file = ""
        relevant_filepath = ""
        if len(product_matches_list) > 0:
            for row in product_matches_list:
                product_version_in_list = row[0]
                product_path_in_list = row[1]
                product_license_key_in_list = row[2]
                product_license_file_in_list = row[3]
                if product_version_in_list == "":
                    product_version_in_list = "1"
                self.output(
                    "Checking version: {}".format(product_version_in_list)
                )  #  GP test
                # remove any letters from start of string (thanks EndNote...)
                if APLooseVersion(product_version_in_list) > APLooseVersion(
                    latest_version
                ):
                    if major_version and not product_version_in_list.startswith(
                        major_version
                    ):
                        continue
                    latest_version = product_version_in_list
                    self.output("Newer version found: {}".format(latest_version))
                    relevant_filepath = product_path_in_list
                    self.output("Path: {}".format(relevant_filepath))
                    latest_license = product_license_key_in_list
                    self.output("License key: {}".format(latest_license))
                    latest_license_file = product_license_file_in_list
                    self.output("License file: {}".format(latest_license_file))
                else:
                    self.output(
                        "Checking version: {}".format(product_version_in_list)
                    )  #  GP test

            try:
                latest_product_details = [
                    latest_version,
                    relevant_filepath,
                    latest_license,
                    latest_license_file,
                ]
            except UnboundLocalError:
                raise ProcessorError("No new version found!")
        else:
            raise ProcessorError("Empty output from SubDirectoryList!")
        return latest_product_details

    def find_installer(self, file_path, product_repo, additional_filter):
        """Grab the DMG or PKG from the path."""
        # Grabbing the newest DMG or PKG works for most of the apps.
        # But for some we need to add an additional filter
        if additional_filter:
            self.output(
                "Looking for installers in {}/{} with filter {}".format(
                    product_repo, file_path, additional_filter
                ),
                verbose_level=2,
            )
        else:
            self.output(
                "Looking for installers in {}/{}".format(product_repo, file_path),
                verbose_level=2,
            )
        try:
            newest_file = max(
                glob.iglob(
                    os.path.join(
                        product_repo,
                        file_path,
                        "*{}*.[DdPp][MmKk][Gg]".format(additional_filter),
                    )
                ),
                key=os.path.getctime,
            )
        except ValueError:
            raise ProcessorError(
                "No dmg or pkg found in {}/{}".format(product_repo, file_path)
            )
        return newest_file

    def main(self):
        """do the main things"""
        # import variables from recipe
        product_name = self.env.get("LIST_NAME")
        product_language = self.env.get("LIST_LANGUAGE")
        # product_license = self.env.get('LICENSE')
        product_list_file = self.env.get("list_source")
        file_delimiter = str(self.env.get("list_delimiter"))
        title_column = int(self.env.get("title_col"))
        language_column = int(self.env.get("lang_col"))
        license_column = int(self.env.get("license_col"))
        license_file_column = int(self.env.get("license_file_col"))
        version_column = int(self.env.get("version_col"))
        path_column = int(self.env.get("path_col"))
        product_repo = self.env.get("mounted_repo")
        self.output("product_repo: {}".format(product_repo))
        recipe_cache_dir = self.env.get("RECIPE_CACHE_DIR")
        major_version = self.env.get("MAJOR_VERSION")
        additional_filter = self.env.get("LIST_FILTER")
        downloads_dir = os.path.join(recipe_cache_dir, "downloads")

        # create a list from the csv
        product_list = self.get_list(product_list_file, file_delimiter)

        # filter the list to the chosen product and language
        product_matches_list = self.get_product_list(
            product_list,
            product_name,
            product_language,
            title_column,
            version_column,
            language_column,
            path_column,
            license_column,
            license_file_column,
        )

        # get the latest version from the matched list
        if major_version:
            self.output("Search restricted to major version: {}".format(major_version))
            latest_product_details = self.get_latest_version(
                product_matches_list, str(major_version)
            )
        else:
            latest_product_details = self.get_latest_version(product_matches_list)

        self.env["version"] = latest_product_details[0]
        self.output("Latest version: {}".format(self.env["version"]))

        file_path_in_list = latest_product_details[1]
        file_path_in_list_basename = os.path.basename(file_path_in_list)
        self.output("Latest folder: {}".format(file_path_in_list_basename))

        file_path = self.find_installer(
            file_path_in_list_basename, product_repo, additional_filter
        )
        self.env["file_path"] = file_path
        self.output("File path of latest version: {}".format(file_path))
        self.env["file_dir"] = os.path.dirname(file_path)
        self.env["latest_file"] = os.path.basename(file_path)

        local_path = os.path.join(downloads_dir, self.env["latest_file"])
        self.env["local_path"] = local_path

        if os.path.exists(local_path):
            self.output("Path to file in cache: {}".format(local_path))
            self.output(
                "File {} is in the AutoPkg Cache".format(self.env["latest_file"])
            )
            self.env["file_exists"] = True
        else:
            self.output(
                "File {} is not in the AutoPkg Cache".format(self.env["latest_file"])
            )
            self.env["file_exists"] = False

        self.env["license_key"] = latest_product_details[2]
        self.output("License Key: {}".format(self.env["license_key"]))

        self.output("License Path (MS-format): {}".format(latest_product_details[3]))

        license_file_path = os.path.join(*latest_product_details[3].split("\\"))
        self.output("License Path: {}".format(license_file_path))
        license_file_basename = os.path.basename(license_file_path)
        _, license_file_dirname = os.path.split(os.path.split(license_file_path)[0])
        self.output("License File Dir Name: {}".format(license_file_dirname))
        self.env["license_file_path"] = "{}/{}".format(
            license_file_dirname, license_file_basename
        )
        self.output("License File Path: {}".format(self.env["license_file_path"]))


if __name__ == "__main__":
    PROCESSOR = InternalUpdateChecker()
    PROCESSOR.execute_shell()
