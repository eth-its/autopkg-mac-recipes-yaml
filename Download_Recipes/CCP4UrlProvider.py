#!/usr/local/autopkg/python
# -*- coding: utf-8 -*-

"""
Based on F5transkriptURLProvider.py by Tim Keller
https://github.com/TK5-Tim/its-unibas-recipes/blob/LogitecSync/F5transkript/F5transkriptURLProvider.py

The resulting link should be formatted similary: https://www.megasoftware.net/do_force_download/MEGAX_10.1.8_installer.pkg
Downloaded artifacts are currently named like : ccp4-9.0.015-shelx-arpwarp-macosarm.tar.gz
"""

from __future__ import absolute_import, print_function
import re
from autopkglib import URLGetter
import sys
import os

try:
    # import for Python 3
    from html.parser import HTMLParser
    import html
except ImportError:
    # import for Python 2
    from HTMLParser import HTMLParser

VERSION_URL = "https://www.megasoftware.net/history"
BASE_URL = "https://www.megasoftware.net/do_force_download/MEGA_"
REGEX = ".*MEGA\ \d{2}\ version\ (\d{2}\.\d\.\d)\ build .*"

# __all__ == ["CCP4URLProvider"]

class CCP4URLProvider(URLGetter):
    """Provides a download URL for the latest version of CCP4"""

    description = __doc__
    input_variables = {
        "USER_AGENT": {"description": "User Agent used for downloading", "required":False, "default":"mozilla macintosh"},
        "latest_version": {"description": "The latest version, as located on the download page", "required":True, "default":"0"}
    }
    output_variables = {
        "url": {"description": "URL to latest version"},
        "version": {"description": "The latest version found"},
        "should_continue": {"description": "TRUEPREDICATE or FALSEPREDICATE depending on Cache directory contents"},
        "CCP4_tgz_file_name": {"description": "filename of the tar.gz to be stored on disk"}
    }

    def main(self):
        USER_AGENT=self.env["USER_AGENT"]
        latest_version=self.env["latest_version"]
        #if sys.version_info.major < 3:
        #    html_source = self.download(VERSION_URL,headers={'User-Agent':USER_AGENT})
        #else:
        #    html_source = self.download(VERSION_URL,headers={'User-Agent':USER_AGENT}).decode("utf-8")
        #escaped_url = re.search(REGEX, html_source).group(1)
        #unescaped_url = html.unescape(escaped_url)
        suffix = "-shelx-arpwarp-macosarm.tar.gz"
        #return_url = BASE_URL + unescaped_url + suffix
        self.env["version"] = latest_version
        return_url='bogus'
        self.env["url"] = return_url

        # if we already have a pkg for the current version, we should not re-download
        # autopkg requires Content-Length, ETAG or Last-Modified headers, but MEGA's web server sends none of these. 
        # if a previous download were incomplete, it would be stored as another/temporary filename, so this should be safeish.

        CCP4_tgz_file_name = "ccp4-" + latest_version + suffix  #ccp4-9.0.015-shelx-arpwarp-macosarm.tar.gz
        working_directory = self.env["RECIPE_CACHE_DIR"] + "/downloads/"

        if os.path.exists(working_directory + CCP4_tgz_file_name) :
            self.env["should_continue"] = False
        else:
            self.env["should_continue"] = True

        self.env["CCP4_tgz_file_name"] = CCP4_tgz_file_name

        print(
            "CCP4URLProvider: Suffix is: %s\n"
            "CCP4URLProvider: Returning full url: %s "
            % (suffix, return_url)
        )

if __name__ == "__main__":
    processor = CCP4URLProvider()
    processor.execute_shell()