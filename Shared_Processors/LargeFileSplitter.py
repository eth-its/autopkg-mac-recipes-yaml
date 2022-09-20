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
"""See docstring for LargeFileSplitter class"""

import os.path

from autopkglib import Processor


__all__ = ["LargeFileSplitter"]


class LargeFileSplitter(Processor):
    """Splits a large file into 500 MB chunks."""

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
        CHUNK_SIZE = 1073741824
        file_number = 1
        with open(large_file_path, "rb") as f:
            chunk = f.read(CHUNK_SIZE)
            while chunk:
                with open(
                    os.path.join(parts_dir, "chunk_" + str(file_number)), "wb"
                ) as chunk_file:
                    chunk_file.write(chunk)
                file_number += 1
                chunk = f.read(CHUNK_SIZE)

    def main(self):
        """Split that file!"""
        large_file_path = self.env.get("large_file_path")
        parts_dir = self.env.get("parts_dir")
        self.split(large_file_path, parts_dir)


if __name__ == "__main__":
    PROCESSOR = LargeFileSplitter()
    PROCESSOR.execute_shell()
