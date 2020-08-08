function Set-LMAPICredential {
    <#
    .SYNOPSIS
        Sets $Global:LogicMonitor hashtable variable with user supplied access ID, access key and LogicMonitor company.

        Will prompt for access key as it is stored as a secure string.
    .EXAMPLE
        Set-LMAPICredential -accessID 'abc123' -company 'acme'

        After pressing enter, the user will be prompted to enter the access key.
    .INPUTS
        System.String
    .OUTPUTS
        System.Collections.Hashtable
    .NOTES
        Ask your company's LogicMonitor administrator for an access ID, access key and company name (as used by LogicMonitor).

        To view the credentials, simply type "$Global:LogicMonitor" from the PowerShell CLI

        To view the (secure string) access key as plain text, use "ConvertFrom-SecureString $Global:LogicMonitor.accessKey -AsPlainText"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $accessID,

        [Parameter(Mandatory)]
        [securestring] $accessKey,

        [Parameter(Mandatory)]
        [string] $company
    )

    process {
        $Global:LogicMonitor = @{}
        $Global:LogicMonitor.add('accessID', $accessID)
        $Global:LogicMonitor.add('accessKey', $accessKey)
        $Global:LogicMonitor.add('company', $company)

        $Global:LogicMonitor
    }
}
