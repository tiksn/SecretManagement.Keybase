[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $FullNameFilter
)

Invoke-psake -taskList Test -parameters @{FullNameFilter = $FullNameFilter }
