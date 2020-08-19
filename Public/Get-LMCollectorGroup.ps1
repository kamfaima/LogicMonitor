function Get-LMCollectorGroup {
    <#
    .SYNOPSIS
        Returns LogicMonitor Collector Groups unless given an Id or request
        parameter to filter the results.
    .DESCRIPTION
        By default, returns 50 LogicMonitor Collector Groups unless given an Id
        or request parameter to filter the results.
    .EXAMPLE
        Get-LMCollectorGroup

        Returns ALL Collector Groups in LogicMonitor. Can be time consuming so
        use the size=n request parameter to limit the number of devices
        returned.
    .EXAMPLE
        Get-LMCollectorGroup -Id 4

        Returns Collector Group with Id 4
    .EXAMPLE
        Get-LMCollectorGroup -RequestParameters "sort=-Id"

        Returns array with elements in descending Collector Group Id order
    .INPUTS
        System.String System.Int32
    .OUTPUTS
        System.Object
    .Link
        LogicMonitor REST API v2 for Collector Groups can be found here:
        https://www.logicmonitor.com/swagger-ui-master/dist/
    #>

    [CmdletBinding(DefaultParameterSetName = "none")]
    param (
        [Parameter(ParameterSetName = "Id")]
        [ValIdateRange("Positive")]
        [Int32] $Id,

        [Parameter()]
        [string] $RequestParameters
    )

    process {
        $uri = "/setting/collector/groups"

        switch ($PSCmdlet.ParameterSetName) {
            "Id" {
                $uri += "/$Id"
            }
        }

        $response = Invoke-LMRestMethod -Method "GET" -Uri $uri -RequestParameters $RequestParameters

        if ($null -ne $response) {
            $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.CollectorGroup") }
        }

        $response
    }

}