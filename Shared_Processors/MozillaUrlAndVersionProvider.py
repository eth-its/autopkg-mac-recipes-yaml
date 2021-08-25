#!/usr/bin/python
#
# Copyright 2010 Per Olofsson, 2013 Greg Neagle
# Version information added by Graham Pugh 2017
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
"""See docstring for MozillaURLandVersionProvider class"""

from __future__ import absolute_import

import json
from autopkglib import URLGetter, ProcessorError  # pylint: disable=import-error


__all__ = ["MozillaUrlAndVersionProvider"]


MOZ_BASE_URL = "https://download.mozilla.org/?product=%s-%s-SSL&os=osx&lang=%s"
MOZ_VERSIONS_URL = "https://product-details.mozilla.org/1.0/%s_versions.json"

# As of 16 Nov 2015 here are the supported products:
# firefox-latest
# firefox-esr-latest
# firefox-beta-latest
# thunderbird-latest
# thunderbird-beta-latest
#
# See also:
#    http://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
#    http://ftp.mozilla.org/pub/firefox/releases/latest-esr/README.txt
#    http://ftp.mozilla.org/pub/firefox/releases/latest-beta/README.txt
#    http://ftp.mozilla.org/pub/thunderbird/releases/latest/README.txt
#    http://ftp.mozilla.org/pub/thunderbird/releases/latest-beta/README.txt


class MozillaUrlAndVersionProvider(URLGetter):
    """Provides URL to the latest Firefox release."""

    description = __doc__
    input_variables = {
        "product_name": {
            "required": True,
            "description": "Product to fetch URL for. One of 'firefox', 'thunderbird'.",
        },
        "release": {
            "required": False,
            "default": "latest",
            "description": (
                "Which release to download. Examples: 'latest', "
                "'esr-latest', 'beta-latest'. Defaults to 'latest'"
            ),
        },
        "locale": {
            "required": False,
            "default": "en-US",
            "description": "Which localization to download, default is 'en-US'.",
        },
        "base_url": {
            "required": False,
            "description": "Default is '%s." % MOZ_BASE_URL,
        },
        "versions_url": {
            "required": False,
            "description": "Default is '%s." % MOZ_VERSIONS_URL,
        },
    }
    output_variables = {
        "url": {"description": "URL to the latest Mozilla product release."},
    }

    def get_version(self, versions_url, product_name, release):
        """Get the appropriate version number of Mozilla product"""
        # Determine correct key name in versions json file
        if release == "latest":
            versions_json_name = "LATEST_%s_VERSION" % product_name.upper()
        if release == "esr-latest":
            versions_json_name = "%s_ESR" % product_name.upper()
        if release == "beta-latest":
            versions_json_name = "LATEST_%s_DEVEL_VERSION" % product_name.upper()

        product_versions_url = versions_url % product_name

        try:
            output = self.download(product_versions_url)
        except Exception as e:
            raise ProcessorError("Can't get the product versions: %s" % e)

        data = json.loads(output)
        return data[versions_json_name]

    def get_mozilla_dmg_url(
        self, base_url, versions_url, product_name, release, locale
    ):
        """Assemble download URL for Mozilla product"""
        # pylint: disable=no-self-use
        # Allow locale as both en-US and en_US.
        locale = locale.replace("_", "-")

        # fix releases into new format
        if release == "latest-esr":
            release = "esr-latest"
        if release == "latest-beta":
            release = "beta-latest"

        # Get required version
        requested_version = self.get_version(versions_url, product_name, release)

        # Construct download URL.
        return base_url % (product_name, requested_version, locale)

    def main(self):
        """Provide a Mozilla download URL"""
        # Determine product_name, release, locale, and base_url.
        product_name = self.env["product_name"]
        release = self.env.get("release", "latest")
        locale = self.env.get("locale", "en-US")
        base_url = self.env.get("base_url", MOZ_BASE_URL)
        versions_url = self.env.get("versions_url", MOZ_VERSIONS_URL)

        self.env["url"] = self.get_mozilla_dmg_url(
            base_url, versions_url, product_name, release, locale
        )
        self.output("Found URL %s" % self.env["url"])


if __name__ == "__main__":
    PROCESSOR = MozillaUrlAndVersionProvider()
    PROCESSOR.execute_shell()
