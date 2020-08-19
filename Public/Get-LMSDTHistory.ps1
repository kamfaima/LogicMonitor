function Get-LMSDTHistory {
    <#
    .SYNOPSIS
        Returns LogicMonitor SDT history for a device (by ID or display name), device group, website or website
        group
    .EXAMPLE
        Get-LMSDTHistory

        By default, with no parameters, prompts for a device display name.
    .EXAMPLE
        Get-LMSDTHistory -DeviceId 4

        Returns SDT history for device ID 4
    .EXAMPLE
        Get-LMSDTHistory -DeviceGroupId 2

        Returns SDT history for device group ID 4
    .EXAMPLE
        Get-LMSDTHistory -DeviceDisplayName "my server""

        Returns SDT history for device display name "my server". This calls Get-LMDevice to retrieve the ID.
    .EXAMPLE
        Get-LMSDTHistory -WebsiteId 4

        Returns SDT history for website with ID 4.
    .EXAMPLE
        Get-LMSDTHistory -WebsiteGroupId 2

        Returns SDT history for website group with ID 2.
    .INPUTS
        System.String System.Int32
    .OUTPUTS
        System.Object
    .Link
        LogicMonitor REST API v2 for Collectors can be found here:
        https://www.logicmonitor.com/swagger-ui-master/dist/
    #>

    [CmdletBinding(DefaultParameterSetName = "DeviceDisplayName")]
    param (
        [Parameter(ParameterSetName = "DeviceGroupId")]
        [Int32] $DeviceGroupID,

        [Parameter(ParameterSetName = "DeviceId")]
        [Int32] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "DeviceDisplayName")]
        [String] $DeviceDisplayName,

        [Parameter(ParameterSetName = "WebsiteId")]
        [Int32] $WebsiteId,

        [Parameter(ParameterSetName = "WebsiteGroupId")]
        [Int32] $WebsiteGroupId,

        [Parameter()]
        [String] $RequestParameters
    )

    process {

        switch ($PSCmdlet.ParameterSetName) {
            "DeviceGroupId" {
                $uri = "/device/groups/$DeviceGroupId/historysdts"
            }
            "DeviceId" {
                $uri = "/device/devices/$DeviceID/historysdts"
            }
            "DeviceDisplayName" {
                $Id = (Get-LMDevice -DisplayName $DeviceDisplayName).id
                $uri = "/device/devices/$Id/historysdts"
            }
            "WebsiteId" {
                $uri = "/website/websites/$WebsiteID/historysdts"
            }
            "WebsiteGroupId" {
                $uri = "/website/groups/$WebsiteGroupID/historysdts"
            }

        }

        $response = Invoke-LMRestMethod -Method "GET" -Uri $uri -RequestParameters $RequestParameters

        if ($null -ne $response) {
            $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.SDTHistory") }
        }

        $response
    }
}