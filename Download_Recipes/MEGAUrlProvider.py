#!/usr/local/autopkg/python
# -*- coding: utf-8 -*-

"""
Based on F5transkriptURLProvider.py by Tim Keller
https://github.com/TK5-Tim/its-unibas-recipes/blob/LogitecSync/F5transkript/F5transkriptURLProvider.py

The resulting link should be formatted similary: https://www.megasoftware.net/do_force_download/MEGAX_10.1.8_installer.pkg
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

# __all__ == ["MEGAURLProvider"]

class MEGAURLProvider(URLGetter):
    """Provides a download URL for the latest version of MEGA"""

    description = __doc__
    input_variables = {
        "USER_AGENT": {"description": "User Agent used for downloading", "required":False, "default":"mozilla macintosh"}
    }
    output_variables = {
        "url": {"description": "URL to latest version"},
        "version": {"description": "The latest version found"},
        "should_continue": {"description": "TRUEPREDICATE or FALSEPREDICATE depending on Cache directory contents"},
        "MEGA_pkg_file_name": {"description": "filename of the pkg to be stored on disk"}
    }

    def main(self):
        USER_AGENT=self.env["USER_AGENT"]
        if sys.version_info.major < 3:
            html_source = self.download(VERSION_URL,headers={'User-Agent':USER_AGENT})
        else:
            html_source = self.download(VERSION_URL,headers={'User-Agent':USER_AGENT}).decode("utf-8")
        escaped_url = re.search(REGEX, html_source).group(1)
        unescaped_url = html.unescape(escaped_url)
        suffix = "_installer.pkg"
        return_url = BASE_URL + unescaped_url + suffix
        self.env["version"] = escaped_url
        self.env["url"] = return_url

        # if we already have a pkg for the current version, we should not re-download
        # autopkg requires Content-Length, ETAG or Last-Modified headers, but MEGA's web server sends none of these. 
        # if a previous download were incomplete, it would be stored as another/temporary filename, so this should be safeish.

        MEGA_pkg_file_name = "MEGA_" + unescaped_url + suffix
        working_directory = self.env["RECIPE_CACHE_DIR"] + "/downloads/"

        if os.path.exists(working_directory + MEGA_pkg_file_name) :
            self.env["should_continue"] = False
        else:
            self.env["should_continue"] = True

        self.env["MEGA_pkg_file_name"] = MEGA_pkg_file_name

        print(
            "MEGAURLProvider: Match found is %s\n"
            "MEGAURLProvider: Unescaped url is: %s\n"
            "MEGAURLProvider: Suffix is: %s\n"
            "MEGAURLProvider: Returning full url: %s "
            % (escaped_url, unescaped_url, suffix, return_url)
        )

if __name__ == "__main__":
    processor = MEGAURLProvider()
    processor.execute_shell()