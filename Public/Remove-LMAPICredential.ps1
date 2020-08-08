function Remove-LMAPICredential {
    <#
    .SYNOPSIS
        Removes the $Global:LogicMonitor variable
    .EXAMPLE
        Remove-LMAPICredential
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        No confirmation is given
    #>

    [CmdletBinding()]
    param ()

    process {
        Remove-Variable -Name LogicMonitor -Scope Global
    }

}
