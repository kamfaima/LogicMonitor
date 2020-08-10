function ConvertTo-CamelCaseHashtable {
    <#
    .SYNOPSIS
        Converts a given hashtable's keys to camelCase
    .DESCRIPTION
        Converts a given hashtable's keys to camelCase.

        This is a helper/intermediate function to ensure our code meets two (contradictory) points:
            1. The PowerShell best practices of using PascalCase for naming all public identifiers
            2. LogicMonitor expects properties to be in camelCase

        The calling function will pass the automatic variable $PSBoundParameters to this function. The (PascalCase)
        keys will be converted to camelCase and returned as a new hashtable.

        Typically only called by Add-LM* functions that have data in the body.
    .EXAMPLE
        ConvertTo-CamelCaseHashtable -InputHashtable $myPascalCaseKeysHashtable

        Converts the keys in $myPascalCaseKeysHashtable and returns a hashtable with cameelCase keys
    .INPUTS
        Hashtable
    .OUTPUTS
        Hashtable
    #>
    param (
        [hashtable] $InputHashtable
    )

    $outputHashtable = @{}

    foreach ($key in $inputHashtable.Keys) {
        $camelCaseKey = $key.Substring(0,1).ToLower()+$key.Substring(1)
        $outputHashtable.Add($camelCaseKey,$inputHashtable.$key)
    }

    $outputHashtable

}