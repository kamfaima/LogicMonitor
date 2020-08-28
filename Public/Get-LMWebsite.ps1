function Get-LMWebsite {
    <#
    .SYNOPSIS
        Returns a LogicMonitor Website
    .DESCRIPTION
        By default, returns ALL LogicMonitor Website unless given an Id, name or domain to filter the results.
    .EXAMPLE
        Get-LMWebsite

        Returns ALL Website in LogicMonitor. Can be time consuming so use the size=n request parameter to limit
        the number of Websites returned.
    .EXAMPLE
        Get-LMWebsite -Id 4

        Returns Website with Id 4
    .EXAMPLE
        Get-LMWebsite -Name "ACME"

        Returns all Websites with "ACME" in its name.
    .EXAMPLE
        Get-LMWebsite -Domain "example.com"

        Returns all Websites with "example.com" in its FQDN.
    .EXAMPLE
        Get-LMWebsite -RequestParameters "size=5"

        Returns 5 Websites
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
        [Parameter(ParameterSetName = "Id")]
        [ValIdateRange("Positive")]
        [Int32]
        $Id,

        [Parameter(Position = 0, ParameterSetName = "Name")]
        [String]
        $Name,

        [Parameter(ParameterSetName = "Domain")]
        [String]
        $Domain,

        [Parameter()]
        [String]
        $RequestParameters
    )

    process {
        $uri = "/website/websites"

        switch ($PSCmdlet.ParameterSetName) {
            "Id" {
                $uri += "/$Id"
            }
            "Name" {
                $RequestParameters += "filter=name~`"$Name`""
            }
            "Domain" {
                $RequestParameters += "filter=domain~`"$Domain`""
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
            $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.Website") }

        }

        $response
    }
}