function Remove-LMDevice {
    <#
    .SYNOPSIS
        Removes a device from LogicMonitor.
    .EXAMPLE
        Remove-LMDevice -Id 45

        Removes a device with Id 45
    .EXAMPLE
        Get-LMDevice -hostname "server" | Remove-LMDevice

        Calls Get-LMDevice to get device with hostname "server" then removes it.
    .NOTES
        By default, will ask for confirmation before deleting device. To
        override use -confirm:$false or -Force
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Int32]
        $Id,

        [Parameter()]
        [Switch]
        $Force
    )

    process {
        $uri = "/device/devices/$Id"

        if ($Force) {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ShouldProcess($Id,"Remove device from LogicMonitor")) {
            $null = Invoke-LMRestMethod -method "DELETE" -uri $uri
        }

    }

}