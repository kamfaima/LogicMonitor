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
        Get-LMSDT -DeviceDisplayName "myServer"

        Returns all SDTs belonging to myServer. This is a wrapper around a filter by deviceDisplayName in a
        request parameter
    .EXAMPLE
        Get-LMSDT -DeviceId 56

        Returns SDTs for device with ID 56.
    .EXAMPLE
        Get-LMSDT -WebsiteId 4

        Returns SDTs for website with ID 4.
    .EXAMPLE
        Get-LMSDT -WebsiteGroupId 2

        Returns SDTs for website group with ID 2.
    .INPUTS
        System.String System.Int32
    .OUTPUTS
        System.Object
    .NOTES
        SDT IDS are not numerical. They are made up of letters and numbers and are returned as strings by the
        LogicMonitor API.
    .Link
        LogicMonitor REST API v2 for Collectors can be found here:
        https://www.logicmonitor.com/swagger-ui-master/dist/
    #>

    [CmdletBinding(DefaultParameterSetName = 'none')]
    param (
        [Parameter(ParameterSetName = "Id")]
        [String] $Id,

        [Parameter(ParameterSetName = "DeviceDisplayName")]
        [String] $DeviceDisplayName,

        [Parameter(ParameterSetName = "DeviceId")]
        [Int32] $DeviceId,

        [Parameter(ParameterSetName = "WebsiteId")]
        [Int32] $WebsiteId,

        [Parameter(ParameterSetName = "WebsiteGroupId")]
        [Int32] $WebsiteGroupId,

        [Parameter()]
        [String] $RequestParameters
    )

    process {
        $uri = "/sdt/sdts"

        switch ($PSCmdlet.ParameterSetName) {
            "Id" {
                $uri += "/$Id"
            }
            "DeviceDisplayName" {
                $RequestParameters += "&filter=deviceDisplayName~`"$DeviceDisplayName`""
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

        $response = Invoke-LMRestMethod -Method "GET" -Uri $uri -RequestParameters $RequestParameters

        if ($null -ne $response) {
            $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.SDT") }
        }

        $response
    }
}