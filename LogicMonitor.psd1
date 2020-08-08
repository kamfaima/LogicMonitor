@{
    # If authoring a script module, the RootModule is the name of your .psm1 file
    RootModule = 'LogicMonitor.psm1'

    Author = 'Kam Fai Ma (kamfai.ma at secureagility.com)'

    CompanyName = 'Secure Agility'

    ModuleVersion = '0.1'

    # Use the New-Guid command to generate a GUID, and copy/paste into the next line
    GUID = '78d580f2-efec-4c56-9073-92dfe0efd8e2'

    Description = 'LogicMonitor helper functions'

    # Minimum PowerShell version supported by this module (optional, recommended)
     PowerShellVersion = '5.1'

    # Which PowerShell Editions does this module work with? (Core, Desktop)
    CompatiblePSEditions = @('Desktop', 'Core')

    # Which PowerShell functions are exported from your module? (eg. Get-CoolObject)
    FunctionsToExport = @(
                            'Add-LMDevice',
                            'Get-LMCollector',
                            'Get-LMCollectorGroup',
                            'Get-LMDevice',
                            'Invoke-LMRestMethod',
                            'Remove-LMAPICredential',
                            'Remove-LMDevice',
                            'Set-LMAPICredential'
                        )

    # Which PowerShell aliases are exported from your module? (eg. gco)
    AliasesToExport = @('')

    # Which PowerShell variables are exported from your module? (eg. Fruits, Vegetables)
    VariablesToExport = @('')

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @(
                            'ObjectDefinitions/LogicMonitor.Device.ps1xml',
                            'ObjectDefinitions/LogicMonitor.Collector.ps1xml',
                            'ObjectDefinitions/LogicMonitor.CollectorGroup.ps1xml'
                        )
}
