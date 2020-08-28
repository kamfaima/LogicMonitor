function Get-LMSDT {
    <#
    .SYNOPSIS
        Returns LogicMonitor SDTs.
    .DESCRIPTION
        Returns LogicMonitor SDTs unless given an ID, device ID, website ID or website group ID or request
        parameter to filter the results

        Retrieving a SDT by device display name is simply a wrapper around the filter property in a request
        parameter.
    .EXAMPLE
        Get-LMSDT

        Returns SDTs in LogicMonitor. Can be time consuming if there are many SDTs so use the size=n request
        parameter to limit the number of SDTs returned.
    .EXAMPLE
        Get-LMSDT -Id "DSI_427"

        Returns SDT with ID "DSI_427".
    .EXAMPLE
        Get-LMSDT "myServer"

        Returns all SDTs belonging to myServer. This doesn't use LM's filter by deviceDisplayName in a request
        parameter. See NOTES section below.
    .EXAMPLE
        Get-LMSDT -DeviceId 56

        Returns SDTs for device with ID 56.
    .EXAMPLE
        Get-LMSDT -WebsiteId 4

        Returns SDTs for website with ID 4.
    .EXAMPLE
        Get-LMSDT -WebsiteGroupId 2

        Returns SDTs for website group with ID 2.
    .EXAMPLE
        Get-LMSDT -WebsiteName "example.com"

        Returns SDTs for websites with "example.com" in its name.  This doesn't use LM's filter by
        deviceDisplayName in a request parameter. See NOTES section below.
    .EXAMPLE
        Get-LMSDT -Admin "Bill Gates"

        Returns SDTs created by "Bill Gates". This doesn't use LM's filter by deviceDisplayName in a request
        parameter. See NOTES section below.
    .INPUTS
        System.String System.Int32
    .OUTPUTS
        System.Object
    .NOTES
        SDT IDS are not numerical. They are made up of letters and numbers and are returned as strings by the
        LogicMonitor API.
    .NOTES
        There seems to be a bug where filtering by deviceDisplayName as a request parameter, i.e.
        'filter=deviceDisplayName:"myServer"' returns SDT instances of myServer INCLUDING SDTs which do not have a
        deviceDisplayName property, e.g. collectors and device groups.

        In scenarios like this it is preferable to pipe the output of Get-LMSDT to PowerShell's native Where-Object
        cmdlet. e.g. Get-LMSDT | Where-Object { $_.deviceDisplayName -match "myServer" }

        The -Admin and -DeviceDisplayName parameters use PowerShell's Where-Object after the initial request has
        returned to perform filtering.
    .Link
        LogicMonitor REST API v2 for Collectors can be found here:
        https://www.logicmonitor.com/swagger-ui-master/dist/
    #>

    [CmdletBinding(DefaultParameterSetName = 'none')]
    param (
        [Parameter(ParameterSetName = "Id")]
        [String] $Id,

        [Parameter(Position = 0, ParameterSetName = "DeviceDisplayName")]
        [String] $DeviceDisplayName,

        [Parameter(ParameterSetName = "DeviceId")]
        [ValidateRange("Positive")]
        [Int32] $DeviceId,

        [Parameter(ParameterSetName = "WebsiteId")]
        [ValidateRange("Positive")]
        [Int32] $WebsiteId,

        [Parameter(ParameterSetName = "WebsiteGroupId")]
        [ValidateRange("Positive")]
        [Int32] $WebsiteGroupId,

        [Parameter(ParameterSetName = "WebsiteName")]
        [String] $WebsiteName,

        [Parameter(ParameterSetName = "Admin")]
        [String] $Admin,

        [Parameter()]
        [String] $RequestParameters
    )

    process {
        $uri = "/sdt/sdts"

        switch ($PSCmdlet.ParameterSetName) {
            "Id" {
                $uri += "/$Id"
            }
            "DeviceId" {
                $uri = "/device/devices/$DeviceID/sdts"
            }
            "WebsiteId" {
                $uri = "/website/websites/$WebsiteID/sdts"
            }
            "WebsiteGroupId" {
                $uri = "/website/groups/$WebsiteGroupID/sdts"
            }

        }

        try {
            $response = Invoke-LMRestMethod -Method "GET" -Uri $uri -RequestParameters $RequestParameters
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        # Insert TypeNames to define formatting only if $response is not null as request parameter query to
        # Invoke-LMRestMethod can return zero results, i.e. null
        if ($null -ne $response) {
            $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.SDT") }
        }

        # Use PowerShell to filter response rather than using a filter in the request parameter
        switch ($PSCmdlet.ParameterSetName) {
            "Admin" {
                $response | Where-Object { $_.admin -match "$admin" }
            }
            "DeviceDisplayName" {
                $response | Where-Object { $_.deviceDisplayName -match "$DeviceDisplayName" }
            }
            "WebsiteName" {
                $response | Where-Object { $_.websiteName -match "$WebsiteName" }
            }
            Default {
                $response
            }
        }
    }
}