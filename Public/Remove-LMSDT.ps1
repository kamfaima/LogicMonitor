function Remove-LMSDT {
    <#
    .SYNOPSIS
        Removes a specified SDT.

        Does not remove any historical SDTs.
    .EXAMPLE
        Remove-LMSDT "H_234"

        Removes SDT with Id H_234
    .EXAMPLE
        Remove-LMSDT -Id "DSI_14"

        Removes SDT with Id DSI_14
    .EXAMPLE
        Get-LMSDT | Remove-LMSDT

        *** WARNING!!! *** Calls Get-LMSDT to get all SDTs then removes it. Although it does ask for user
        confirmation it is much better to filter the results.
    .EXAMPLE
        Get-LMSDT | Where-Object { $_.deviceDisplayName -match "myServer" } | Remove-LMSDT

        Calls Get-LMSDT, pipes the output through Where-Object to get devices with hostname "myserver", then
        removes any SDTs associated with it.
    .EXAMPLE
        Get-LMSDT -Id "DSI_493" | Remove-LMSDT

        Calls Get-LMSDT to get SDT with Id "DSI_493" then removes it.
    .NOTES
        By default, will ask for confirmation before deleting device. To
        override use -confirm:$false or -Force
    .NOTES
        Does not give errors when attempting to delete non-existent SDT, therefore we cannot catch/throw a
        meaningful message.
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        $Id,

        [Parameter()]
        [Switch]
        $Force
    )

    process {
        $uri = "/sdt/sdts/$Id"

        if ($Force) {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ShouldProcess($Id,"Remove SDT")) {
            $null = Invoke-LMRestMethod -method "DELETE" -uri $uri
        }
    }
}