function Edit-LMDevice {
    <#
    .SYNOPSIS
        Edits a device in LogicMonitor by adding or editing existing device properties
    .DESCRIPTION
        Adds a device into LogicMonitor, places it into an appropriate device group (hostGroupIds) and assigns it
        to a collector, collector group or auto-balancing collector group.
    .EXAMPLE
        Edit-LMDevice -name "server" -displayName "My server" -preferredCollectorId 5 -hostgroupIds 45

        Adds a device with IP Address/DNS name of "server", display name of "My server" using the collector with
        id 5 and places it in the device group (hostgroup) with id 45
    .EXAMPLE
        Edit-LMDevice -name "server" -displayName "My server" -autoBalancedCollectorGroupId 12 -hostgroupIds 2

        Adds a device with IP Address/DNS name of "server", display name of "My server" using the auto-balancing
        collector group with id 12 and places it in the device group (hostgroup) with id 2
    .NOTES
        General notes
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="Id")]
        [String]
        $Id,

        [Parameter(Mandatory, ParameterSetName="Name")]
        [String]
        $Name,

        [Parameter(Mandatory)]
        [String]
        $Data,

        [Parameter()]
        [String]
        $CustomProperties

    )

    process {
        $uri = "/device/devices"

        # $camelCaseParams = ConvertTo-CamelCaseHashtable -InputHashtable $Data
        # $data = ConvertTo-Json -InputObject $camelCaseParams

        switch ($PSCmdlet.ParameterSetName) {
            "Id" {

            }
            "Name" {
                $Id = (Get-LMDevice -DisplayName $Name).id
            }
        }

        if ($PSCmdlet.ShouldProcess($displayName,"Edit device")) {
            $response = Invoke-LMRestMethod -Method "PATCH" -Uri $uri -data $data
            $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.Device") }

            $response
        }
    }

}