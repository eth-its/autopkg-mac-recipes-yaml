#!/usr/local/autopkg/python
#
# Copyright 2014 Arjen van Bochoven
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


from __future__ import absolute_import

import json

from autopkglib import Processor, ProcessorError, URLGetter

__all__ = ["OperaURLProvider"]

class OperaURLProvider(URLGetter):
    description = "Provides URL to the latest stable version."
    input_variables = {
        "USER_AGENT": {"description": "User Agent used for downloading", "required":False, "default":"Opera autoupdate agent/1.0.0"},
        "arch": {"description": "Architecture - arm64 or x86_64", "required":True, "default":"arm64"}
    }
    output_variables = {
        "url": { "description": "URL for a download.", },
        "version": { "description": "Application version.", },
        "filename": { "description": "Filename for the zip file.", }
    }

    __doc__ = description

    def get_feed_data(self, url, USER_AGENT,ARCH):
        """Returns a dict containing:
            version: latest
            url: Url for the zip archive
        """

        url = "https://autoupdate.geo.opera.com/netinstaller/Stable/MacOS/" + ARCH

        try:
            data = self.download(url,headers={'User-Agent':USER_AGENT})
        except:
            raise ProcessorError("Can't open URL %s" % url)

        self.output(url)

        # Todo, add a try catch block
        json_data = json.loads(data)

        item = {}
        item["version"] = 'latest'
        item["filename"] = json_data['installer_filename']
        item["url"] = json_data['installer']

        return item

    def main(self):
        latest = self.get_feed_data(self.env.get("update_url"),self.env.get("USER_AGENT"),self.env.get("ARCH"))

        self.output("Version retrieved from opera xml: %s" % latest["version"])

        # Todo: "VERSION" is not the same as declared output variable "version"
        self.env["VERSION"] = latest["version"]
        self.env["url"] = latest["url"]
        self.env["filename"] = latest["filename"]
        self.output("Found URL %s" % self.env["url"])


if __name__ == "__main__":
    processor = OperaURLProvider()
    processor.execute_shell()