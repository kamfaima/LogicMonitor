function Invoke-LMRestMethod {
    <#
    .SYNOPSIS
        This function builds an authenticated request to LogicMonitor's REST API
    .DESCRIPTION
        This function builds an authenticated request to LogicMonitor's REST API v2.

        It does all the heavy lifting such as building the URL given an HTTP method, a URI and optionally any
        request parameters or data.

        It returns a PSCustomObject with the HTTP status code, error message and data returned by the request.
    .EXAMPLE
        Invoke-LMRestMethod -Method "GET" -uri "/setting/collectors" -requestParameters "size=5"

        Creates a HTTP GET request to LogicMonitor to return 5 Collectors
    .EXAMPLE
        Invoke-LMRestMethod -Method "POST" -uri "/device/devices" -data "{'name':'172.16.19.171','displayName':'ProdServer25'}"

        Creates a HTTP POST request to create a device as specified in the
        (shortened for this example) data field.
    .EXAMPLE
        Invoke-LMRestMethod -Method "DELETE" -uri "/setting/roles/3"

        Deletes the role with Id 3
    .INPUTS
        System.String System.Int32
    .OUTPUTS
        A PSCustomObject with the total objects and filtered (if any) items returned by a v2 request (default).
    .NOTES
        Before running this script, ensure the global variable $Global:LogicMonitor has been set. Run
        Set-LMAPIAuthentication to set this.
    .NOTES
        There is no HTTP status code checking. Yet.

        For v2 API requests, check https://www.logicmonitor.com/support/rest-api-developers-guide/v2/#ss-header-71
        for status codes.
    .LINK
        The LogicMonitor REST API can be found here: https://www.logicmonitor.com/support/rest-api-developers-guide

        Some LogicMonitor examples can be found here:
        https://www.logicmonitor.com/support/rest-api-developers-guide/v1/rest-api-v1-examples

        Information on v2 API changes can be found here:
        https://www.logicmonitor.com/support/rest-api-developers-guide/v2/
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("GET", "POST", "PUT", "PATCH", "DELETE", IgnoreCase = $false, ErrorMessage = "'{0}' is invalid. Either the wrong method was used or it wasn't uppercase (HTTP methods must be uppercase). Try one of {1}.")]
        [string] $Method,

        [Parameter(Mandatory)]
        [string] $Uri,

        [Parameter()]
        [string] $RequestParameters = "",

        [Parameter()]
        [string] $Data = ""
    )

    process {
        $count = 0
        $allData = [System.Collections.ArrayList]::new()

        do {
            $fullRequestParameters = "offset=$($count)&$($RequestParameters)"

            <# Use TLS 1.2 #>
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            <# Construct URL #>
            $url = "https://$($Global:LogicMonitor.company).logicmonitor.com/santaba/rest$($Uri)?v=2&$($fullRequestParameters)"

            <# Get current time in milliseconds #>
            $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

            <# Concatenate Request Details #>
            $requestVars = $Method + $epoch + $Data + $Uri

            <# Construct Signature #>
            $hmac = New-Object System.Security.Cryptography.HMACSHA256
            $hmac.Key = [Text.Encoding]::UTF8.GetBytes((ConvertFrom-SecureString -SecureString $Global:LogicMonitor.accessKey -AsPlainText))
            $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
            $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
            $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

            <# Construct Headers #>
            $auth = "LMv1 $($Global:LogicMonitor.accessID):$($signature):$($epoch)"
            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $headers.Add("Authorization", $auth)
            $headers.Add("Content-Type", 'application/json')

            <# Make API Request
                 Might have to add try and catch to cater for 429 status code.
                 See https://www.logicmonitor.com/support/rest-api-developers-guide/overview/using-logicmonitors-rest-api#ss-header-25
                 for more information.
            #>

            $response = Invoke-RestMethod -Uri $url -Method $Method -Header $headers -Body $Data

            <#
                There are four different ways LM will return output data so we need to cater for them all.
                 1. A size=n parameter was supplied which means only return n number of objects
                    - Returns object with .total > 0 and .items = n
                    - Return $repsonse.items
                 2. No arguments were provided which means return all devices
                    - Returns object with .total > 0 and .items in batches of 50
                    - Continue fetching more items
                    - Return $response.items
                 3. The query returns no results (but not because it was malformed, in which case it will throw an error)
                    - Returns object with .total = 0 and empty .items
                    - Return empty collectionlist
                 4. A single device Id was supplied as an argument
                    - Returns just one PSCustomObject, .total does not exist, implies .total = false
                    - Return $response
             #>

            if ($RequestParameters -like "*size=*") {
                Write-Debug "Query limited by size parameter - no loop to return all objects required"
                $response.items | ForEach-Object { [void]$allData.add($_) }
                break
            } elseif ($response.total) {
                # Need to loop through until we fetch all objects
                $total = $response.total
                $count += $response.items.length
                Write-Verbose "Items returned: $count of $total"
                $response.items | ForEach-Object { [void]$allData.add($_) }
            } elseif ($response.total -eq 0) {
                Write-Debug "Returning empty results"
                break
            } else {
                Write-Debug "Returning single result"
                $response | ForEach-Object { [void]$allData.add($_) }
                break
            }

        } while ($count -ne $total)

        return $allData
    }
}