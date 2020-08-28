function Add-LMWebsiteSDT {
    <#
    .SYNOPSIS
        Adds SDT to a Website
    .DESCRIPTION
        Adds SDT to a Website. There are five different schedules of SDT:
            1. one time
            2. daily
            3. weekly (runs once a week on a specific day)
            4. monthly (on specific day)
            5. monthly (on day of week)

        Numbers 2-5 are repeating SDTs and they all have hour, minute, endhour and endminute parameters in common.
        Where they differ are:

            * weekly - uses weekday parameter to specify which day (Sunday - Saturday) the SDT is scheduled
            * monthly (on specified day) - uses monthday (1-31) to specify which day of the month the SDT is scheduled
            * monthly (on day of week) - uses weekofmonth and weekday to specify which day of which week the SDT is scheduled

        All hour parameters are in 24 hour format (0-23) and StartDateTime and EndDateTime use the local timezone.
    .EXAMPLE
        Add-LMWebsiteSDT -SdtType oneTime -Comment "Applying patch" -StartDateTime "23/12/2020 11:00" -EndDatetime "23/12/2020 13:00" -ServiceId 677

        Adds a one time SDT starting at 23/12/2020 11:00 and ending at 23/12/2020 13:00 to Website with Id 677
    .EXAMPLE
        Add-LMWebsiteSDT -SdtType daily -Comment "Nightly maintenance" -Hour 3 -Minute 0 -EndHour 4 -EndMinute 30 -WebsiteDisplayName "myServer01"

        Adds a daily SDT starting at 03:00 and ending at 04:30 to Website with display name "myServer01"
    .EXAMPLE
        Add-LMWebsiteSDT -SdtType weekly -Comment "Reboot every Wednesday" -Hour 22 -Minute 15 -EndHour 22 -EndMinute 30 -WeekDay Wednesday -ServiceId 4

        Adds a weekly SDT that runs every Wednesday at 22:15 and ending at 22:30 to Website with Id 4
    .EXAMPLE
        Add-LMWebsiteSDT -SdtType monthly -Comment "DB rollup" -Hour 2 -Minute 45 -EndHour 3 -EndMinute 45 -MonthDay 16 -WebsiteDisplayName "myDB01"

        Adds a SDT that runs every month on the 16th day starting at 02:45 and ending at 03:45 to Website with display name "myDB01"
    .EXAMPLE
        Add-LMWebsiteSDT -SdtType monthlyByWeek -Comment "Monthly maintenance" -Hour 11 -Minute 55 -EndHour 12 -EndMinute 10 -WeekOfMonth Second -WeekDay Saturday -WebsiteDisplayName "myServer01"

        Adds a SDT that runs on the second Saturday of every month starting at 11:55 and ending at 12:10 to Website with display name "myServer01"
    .NOTES
        LogicMonitor SDTs can only be defined with one continous block of time. To specify more complex SDT
        schedules, e.g. run twice a month, simply create a SDT for every block of time.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("oneTime", "daily", "weekly", "monthly", "monthlyByWeek")]
        [String]
        $SdtType,

        [Parameter()]
        [String]
        $Comment,

        [Parameter(Mandatory, ParameterSetName = "oneTimeByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "oneTimeByWebsiteDisplayName")]
        [String]
        $StartDateTime,

        [Parameter(Mandatory, ParameterSetName = "oneTimeByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "oneTimeByWebsiteDisplayName")]
        [String]
        $EndDateTime,

        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteDisplayName")]
        [ValidateRange(0, 23)]
        [Int]
        $Hour,

        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteDisplayName")]
        [ValidateRange(0, 59)]
        [Int]
        $Minute,

        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteDisplayName")]
        [ValidateRange(0, 23)]
        [Int]
        $EndHour,

        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteDisplayName")]
        [ValidateRange(0, 59)]
        [Int]
        $EndMinute,

        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteDisplayName")]
        [ValidateSet("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")]
        [String]
        $WeekDay,

        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteDisplayName")]
        [ValidateSet("First", "Second", "Third", "Fourth", "Last")]
        [String]
        $WeekOfMonth,

        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteDisplayName")]
        [ValidateRange(1, 31)]
        [Int]
        $MonthDay,

        [Parameter(Mandatory, ParameterSetName = "oneTimeByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteId")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteId")]
        [ValidateRange("Positive")]
        [Int]
        $ServiceId,

        [Parameter(Mandatory, ParameterSetName = "oneTimeByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "dailyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "weeklyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWebsiteDisplayName")]
        [Parameter(Mandatory, ParameterSetName = "monthlyByWeekByWebsiteDisplayName")]
        [String]
        $ServiceName
    )

    process {
        $uri = "/sdt/sdts"

        # LogicMonitor properties are case-sensitive and in camelCase format. In PowerShell, using camelCase for
        # public parameters is not stylistically recommended so we need to convert to a compatible format for
        # LogicMonitor.
        $camelCaseParams = ConvertTo-CamelCaseHashtable -InputHashtable $PSBoundParameters
        $camelCaseParams.add("type", "ServiceSDT")

        # Only oneTime SDTs require epoch time calculations (in milliseconds). Repeating SDTs specify time and date
        # using individual elements
        if ($PSCmdlet.ParameterSetName -like "oneTime*") {
            try {
                [int64] $startDateTimeEpoch = [int64] (Get-Date -Date $StartDateTime -UFormat "%s" -ErrorAction Stop) * 1000
                [int64] $endDateTimeEpoch = [int64] (Get-Date -Date $EndDateTime -UFormat "%s" -ErrorAction Stop) * 1000
            } catch {
                # Terminate due to bad start or end date time
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }

            $camelCaseParams["startDateTime"] = $startDateTimeEpoch
            $camelCaseParams["endDateTime"] = $endDateTimeEpoch
        }

        $data = ConvertTo-Json -InputObject $camelCaseParams

        # Provide a target for the ShouldProcess function if -whatif is used
        if ($ServiceId -gt 0) {
            [int]$targetWebsite = $ServiceId
        } else {
            [String]$targetWebsite = $ServiceName
        }

        if ($PSCmdlet.ShouldProcess($targetWebsite, "Add SDT to Website")) {
            try {
                $response = Invoke-LMRestMethod -Method "POST" -Uri $uri -data $data
            } catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }

            if ($null -ne $response) {
                $response | ForEach-Object { $_.PSObject.TypeNames.Insert(0, "LogicMonitor.SDT") }
            }

            $response
        }
    }
}
