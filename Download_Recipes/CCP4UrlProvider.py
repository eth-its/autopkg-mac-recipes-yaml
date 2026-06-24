#!/usr/local/autopkg/python
# -*- coding: utf-8 -*-

"""
Processor to check for pre-existing (and valid) download given a version number, and return should_continue=False if that is the case.
Download the required installer in case it is not present yet.  

Based on F5transkriptURLProvider.py by Tim Keller
https://github.com/TK5-Tim/its-unibas-recipes/blob/LogitecSync/F5transkript/F5transkriptURLProvider.py


Downloaded artifacts are currently named like : ccp4-9.0.015-shelx-arpwarp-macosarm.tar.gz
"""

from __future__ import absolute_import, print_function
from autopkglib.URLGetter import URLGetter
import os

class CCP4URLProvider(URLGetter):
    """Downloads the latest version of CCP4"""

    description = __doc__
    input_variables = {
        "latest_version": {"description": "The latest version, as located on the download page", "required":True, "default":"0"},
        "sessionid": {"description": "The session id for downloading", "required":True, "default":"0"}
    }
    output_variables = {
        "version": {"description": "The latest version found"},
        "should_continue": {"description": "TRUEPREDICATE or FALSEPREDICATE depending on Cache directory contents"},
        "pathname": {"description": "filename of the tar.gz to be stored on disk"}
    }

    def download_ccp4(sessionid,working_directory,CCP4_tgz_file_name):
        downloadURL=f"https://www.ccp4.ac.uk/download/download_file.php?pkg=ccp4-shelx-arp-arm64&os=macos&sid={sessionid}"

        #first attempt - post that we accept the license for ccp4 ; this might suffice, and if we get a 3GB+ file, we can stop there.
        self.env["curl_opts"] = ['-X','POST','-F',f'id={sessionid}','-F','package=ccp4','-F','result=accept','-F','accept=accept']
        self.download_to_file(downloadURL,working_directory + "first_license_accepted.download")

        if os.path.getsize(working_directory + "first_license_accepted.download") > 3000000000 :
            os.rename(working_directory + "first_license_accepted.download",working_directory + CCP4_tgz_file_name)
            return
        
        else:
            os.remove(working_directory + "first_license_accepted.download")

        #second attempt - post that we accept the license for shelx as well ; 
        self.env["curl_opts"] = ['-X','POST','-F',f'id={sessionid}','-F','package=ccp4','-F','result=accept','-F','accept=accept']
        self.download_to_file(downloadURL,working_directory + CCP4_tgz_file_name)

    def main(self):
        latest_version=self.env["latest_version"]
        suffix = "-shelx-arpwarp-macosarm.tar.gz"
        self.env["version"] = latest_version
        sessionid = self.env["sessionid"]

        CCP4_tgz_file_name = "ccp4-" + latest_version + suffix  #ccp4-9.0.015-shelx-arpwarp-macosarm.tar.gz
        working_directory = self.env["RECIPE_CACHE_DIR"] + "/downloads/"
        self.env["pathname"] = working_directory + CCP4_tgz_file_name

        print("CCP4URLPRovider: checking for presence of : " + working_directory + CCP4_tgz_file_name)
        if os.path.exists(working_directory + CCP4_tgz_file_name) :
            if os.path.getsize(working_directory + CCP4_tgz_file_name) > 3000000000 : 
                self.env["should_continue"] = False
            else:
                os.remove(working_directory + CCP4_tgz_file_name)
                download_ccp4(sessionid,working_directory,CCP4_tgz_file_name)
                self.env["should_continue"] = True
        else:
            download_ccp4(sessionid,working_directory,CCP4_tgz_file_name)
            self.env["should_continue"] = True


if __name__ == "__main__":
    processor = CCP4URLProvider()
    processor.execute_shell()


        