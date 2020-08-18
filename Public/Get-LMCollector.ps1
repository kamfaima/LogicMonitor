function Get-LMCollector {
    <#
    .SYNOPSIS
        Returns LogicMonitor Collectors unless given an Id or request parameter
        to filter the results.
    .DESCRIPTION
        By default, returns 50 LogicMonitor Collectors unless given an Id or
        request parameter to filter the results.
    .EXAMPLE
        Get-LMCollector

        Returns ALL Collectors in LogicMonitor. Can be time consuming so use
        the size=n request parameter to limit the number of devices returned.
    .EXAMPLE
        Get-LMCollector -Id 4

        Returns Collector with Id 4
    .EXAMPLE
        Get-LMCollector -RequestParameters "sort=-Id"

        Returns array with elements in descending Collector Id order
    .INPUTS
        System.String System.Int32
    .OUTPUTS
        System.Object
    .Link
        LogicMonitor REST API v2 for Collectors can be found here:
        https://www.logicmonitor.com/swagger-ui-master/dist/
    #>

    [CmdletBinding(DefaultParameterSetName = "none")]
    param (
        [Parameter(ParameterSetName = "Id")]
        [ValidateRange("Positive")]
        [Int32] $Id,

        [Parameter()]
        [string] $RequestParameters
    )

    process {
        $uri = "/setting/collector/collectors"

        switch ($PSCmdlet.ParameterSetName) {
            "Id" {
                $uri += "/$Id"
            }
        }

        $response = Invoke-LMRestMethod -Method "GET" -Uri $uri -RequestParameters $RequestParameters

        if ($null -ne $response) {
            $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.Collector") }
        }

        $response
    }
}