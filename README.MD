Export Metadata Tables
======================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0) ![This script was last tested in Nuix 9.4](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-9.4-green.svg)

View the GitHub project [here](https://github.com/Nuix/Export-Metadata-Tables) or download the latest release [here](https://github.com/Nuix/Export-Metadata-Tables/releases).

# Overview

This script provides a way to generate PDFs, HTML files and Text files with a listing of metadata for items.

![image](https://user-images.githubusercontent.com/11775738/132750261-fdabe247-ee69-468e-bb15-916ae6740ad6.png)

![image](https://user-images.githubusercontent.com/11775738/132750358-b46585c5-795f-448c-97c2-7acb383eca8e.png)

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

# Usage

Select some items in Nuix to export.  Then enable the types of files you would like produced (PDF, HTML, TXT).  For each you can provide a path template to customize the folder structure and file naming of each.  For a list of supported placeholders, see [Help](https://github.com/Nuix/Export-Metadata-Tables/blob/main/Ruby/ExportMetadataTables.nuixscript/Help.md) (included with script and accessible via script's help menu item).

# Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the script.

This script also relies on code from [SuperUtilities](https://github.com/Nuix/SuperUtilities).  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of SuperUtilities.jar by either:
1. Building it from [the source](https://github.com/Nuix/SuperUtilities)
2. Downloading an already built JAR file from the [SuperUtilities releases](https://github.com/Nuix/SuperUtilities/releases)

Once you also have a copy of SuperUtilities.jar, make sure to include it in the same directory as the script.

# License

```
Copyright 2021 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
