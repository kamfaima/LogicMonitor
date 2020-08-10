function Add-LMDevice {
    <#
    .SYNOPSIS
        Adds a device into LogicMonitor
    .DESCRIPTION
        Adds a device into LogicMonitor, places it into an appropriate device group (hostGroupIds) and assigns it
        to a collector, collector group or auto-balancing collector group.
    .EXAMPLE
        Add-LMDevice -name "server" -displayName "My server" -preferredCollectorId 5 -hostgroupIds 45

        Adds a device with IP Address/DNS name of "server", display name of "My server" using the collector with
        id 5 and places it in the device group (hostgroup) with id 45
    .EXAMPLE
        Add-LMDevice -name "server" -displayName "My server" -autoBalancedCollectorGroupId 12 -hostgroupIds 2

        Adds a device with IP Address/DNS name of "server", display name of "My server" using the auto-balancing
        collector group with id 12 and places it in the device group (hostgroup) with id 2
    .NOTES
        General notes
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [String]
        $Name,

        [Parameter(Mandatory)]
        [String]
        $DisplayName,

        [Parameter(Mandatory, ParameterSetName = "Collector")]
        [Int]
        $PreferredCollectorId,

        [Parameter(Mandatory, ParameterSetName = "CollectorGroup")]
        [Int]
        $PreferredCollectorGroupId,

        [Parameter(Mandatory, ParameterSetName = "ABCG")]
        [Int]
        $AutoBalancedCollectorGroupId,

        [Parameter()]
        [String]
        $HostGroupIds,

        [Parameter()]
        [String]
        $Description,

        [Parameter()]
        [Boolean]
        $DisableAlerting,

        [Parameter()]
        [String]
        $Link,

        [Parameter()]
        [Boolean]
        $EnableNetflow,

        [Parameter()]
        [Int]
        $NetflowCollectorId,

        [Parameter()]
        [String]
        $CustomProperties

    )

    process {
        $uri = "/device/devices"

        # TODO:
        # If we have netflow collectors, we might need to test for netflowCollectorId if
        # $PSBoundParameters.ContainsKey("netflowCollectorId")

        $camelCaseParams = ConvertTo-CamelCaseHashtable -InputHashtable $PSBoundParameters
        $data = ConvertTo-Json -InputObject $camelCaseParams

        if ($PSCmdlet.ShouldProcess($displayName,"Add device to LogicMonitor")) {
            $response = Invoke-LMRestMethod -Method "POST" -Uri $uri -data $data
            $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.Device") }

            $response
        }
    }

}