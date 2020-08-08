function Get-LMDevice {
    <#
    .SYNOPSIS
        Returns LogicMonitor Devices unless given an Id or request parameter to
        filter the results.
    .DESCRIPTION
        By default, returns 50 LogicMonitor Devices unless given an Id or
        request parameter to filter the results.

        Retrieving a device using customer, hostname or displayname parameters
        is simply a wrapper around the filter property in a request parameter.
    .EXAMPLE
        Get-LMDevice

        Returns ALL Devices in LogicMonitor. Can be time consuming so use the
        size=n request parameter to limit the number of devices returned.
    .EXAMPLE
        Get-LMDevice -Id 4

        Returns device with Id 4
    .EXAMPLE
        Get-LMDevice -Customer "ACME"

        Returns all devices belonging to customer ACME. This filters using a
        custom (and inherited property) called "customer.name"
    .EXAMPLE
        Get-LMDevice -Hostname "server"

        Returns all devices with "server" in its name.
    .EXAMPLE
        Get-LMDevice -RequestParameters "sort=-Id"

        Returns array with elements in descending Collector Id order
    .INPUTS
        System.String System.Int32
    .OUTPUTS
        System.Object
    .Link
        LogicMonitor REST API v2 for Collectors can be found here:
        https://www.logicmonitor.com/swagger-ui-master/dist/
    #>

    [CmdletBinding(DefaultParameterSetName = 'none')]
    param (
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [ValIdateRange("Positive")]
        [Int32] $Id,

        [Parameter(ParameterSetName = "Customer")]
        [String] $Customer,

        [Parameter(ParameterSetName = "DisplayName")]
        [String] $DisplayName,

        [Parameter(ParameterSetName = "Hostname")]
        [String] $HostName,

        [Parameter()]
        [String] $RequestParameters
    )

    process {
        $uri = "/device/devices"

        switch ($PSCmdlet.ParameterSetName) {
            "Id" {
                $uri += "/$Id"
            }
            "Customer" {
                $RequestParameters += "&filter=inheritedProperties.name:`"customer.name`",inheritedProperties.value:`"$Customer`""
            }
            "DisplayName" {
                $RequestParameters += "&filter=displayName~`"$DisplayName`""
            }
            "HostName" {
                $RequestParameters += "&filter=name~`"$HostName`""
            }
        }

        $response = Invoke-LMRestMethod -Method "GET" -Uri $uri -RequestParameters $RequestParameters
        $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.Device") }

        $response
    }
}