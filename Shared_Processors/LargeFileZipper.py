#!/usr/local/autopkg/python
#
# Copyright 2022 by Graham Pugh
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
"""See docstring for LargeFileZipper class"""

import os.path
import subprocess

from autopkglib import Processor


__all__ = ["LargeFileZipper"]


class LargeFileZipper(Processor):
    """Zips a large file into 1 GB chunks."""

    description = __doc__
    input_variables = {
        "large_file_path": {
            "required": True,
            "description": ("Path to a large file that should be split up"),
        },
        "parts_dir": {
            "required": True,
            "description": ("Directory to store the split file parts."),
        },
    }
    output_variables = {}

    def split(self, large_file_path, parts_dir):
        """Do the split"""
        CHUNK_SIZE = 1024
        large_file = os.path.basename(large_file_path)
        zip_cmd = (
            f"/usr/bin/zip -r -s {CHUNK_SIZE}M '{parts_dir}/{large_file}.zip' "
            f"{large_file_path}"
        )
        # run the command
        subprocess.check_output(zip_cmd)

    def main(self):
        """Split that file!"""
        large_file_path = self.env.get("large_file_path")
        parts_dir = self.env.get("parts_dir")
        self.split(large_file_path, parts_dir)


if __name__ == "__main__":
    PROCESSOR = LargeFileZipper()
    PROCESSOR.execute_shell()
