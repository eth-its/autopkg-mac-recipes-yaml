# -*- coding: utf-8 -*-
#
# Copyright 2015-2020 Elliot Jordan
# Adapted 2022 Graham Pugh
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

from autopkglib import Processor  # noqa: F401

__all__ = ["MSOfficeVersionSplitter"]


class MSOfficeVersionSplitter(Processor):  # pylint: disable=invalid-name
    """This processor splits version numbers and returns the specified index.
    This version of the processor is designed to just strip the final 4 characters
    off the version string. This is required to obtain the required string to set
    a specific Manifest Server URL for Microsoft AutoUpdate. See
    https://www.kevinmcox.com/2021/10/microsoft-now-provides-curated-deferral-channels-for-autoupdate/
    """

    input_variables = {
        "version": {
            "required": True,
            "description": "The version string that needs splitting.",
        },
    }
    output_variables = {
        "msoffice_version": {"description": "The converted version string."}
    }
    description = __doc__

    def main(self):
        """Main process."""

        self.env["msoffice_version"] = self.env["version"][:-4]
        self.output("Output version: {}".format(self.env["msoffice_version"]))


if __name__ == "__main__":
    PROCESSOR = MSOfficeVersionSplitter()
    PROCESSOR.execute_shell()
