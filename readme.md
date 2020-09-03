# An Unofficial LogicMonitor SDK for PowerShell

This project provides a Microsoft PowerShell module for managing LogicMonitor by way of using their published
RESTful APIs. It's still very much a work in progress so features are being continuously added.


# Installation

Once you've downloaded the module you can either unpack it into a directory of your choosing or into the
$env:PSModulePath - I strongly recommend the latter choice.

If you unpacked it into a directory of your choosing you will have to manually import it by
using:

`Import-Module path\to\LogicMonitor\module\LogicMonitor.psd1`

If you unpacked it into a diretory in $env:PSModulePath then it will auto-load when you attempt to run a command
exported by the function or you can simply type:

`Import-Module LogicMonitor`

# Prerequisites

There are three things you'll need before you can use this LogicMonitor module:
1. Company
2. Access ID
3. Access Key

Consult your LogicMonitor administrator to obtain these.

# Setting Credentials

Once you've obtained the prerequisites, you'll need to run `Set-LMAPICredential`. These will store the three
prerequisites in a global variable called `LogicMonitor`. The module will then refer to this to establish a
connection with the LogicMonitor instance specified by `company`.

# Usage

All functions have comprehensive comment-based help. If something is not working as expected please file a bug
using the Issues link above.