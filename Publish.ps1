[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Locally')]
    [switch]
    $Locally,
    [Parameter(Mandatory = $true, ParameterSetName = 'PSGallery')]
    [switch]
    $PSGallery
)

if ($Locally) {
    Invoke-psake -taskList PublishLocally
}

if ($PSGallery) {
    Invoke-psake -taskList PublishPSGallery
}