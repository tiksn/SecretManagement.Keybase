Task PublishPSGallery -depends PublishLocally {
    if (Get-Module -Name SecretManagement.Keybase) {
        Remove-Module -Name SecretManagement.Keybase
    }

    Import-Module -Name SecretManagement.Keybase

    $apiKey = Get-Secret -Name 'TIKSN-SecretManagementKeybase-PSGallery-ApiKey' -AsPlainText

    Publish-Module -Name SecretManagement.Keybase -Repository PSGallery -NuGetApiKey $apiKey
}

Task Test -Depends ImportModule {
    $result = Invoke-Pester -Script .\test\*.Tests.ps1 -PassThru

    $leftover = $null
    '{"method": "list", "params": {"options": {"namespace": "test"}}}' | keybase kvstore api | Set-Variable leftover
    $leftover = $leftover | ConvertFrom-Json -AsHashtable -Depth 4
    $namespace = $leftover['result']['namespace']
    $entryKeys = $leftover['result']['entryKeys']

    foreach ($entryKey in $entryKeys) {
        $key = $entryKey['entryKey']

        @{
            'method' = 'del'
            'params' = @{ 
                'options' = @{
                    'namespace' = $namespace
                    'entryKey'  = $key
                }
            }
        } | ConvertTo-Json -Depth 4 | keybase kvstore api
    }

    if ($result.FailedCount -ne 0) {
        throw 'Tests failed'
    }
}
 
Task ImportModule -Depends PublishLocally {
    Import-Module .\src\SecretManagement.Keybase.psd1
    
    if (!(Get-Module -Name SecretManagement.Keybase)) {
        throw 'Failed to import module.'
    }
}

Task PublishLocally -depends RemoveModule {
    $documentsDir = [Environment]::GetFolderPath("MyDocuments")
    $powerShellDir = Join-Path -Path $documentsDir -ChildPath 'PowerShell'
    $modulesDir = Join-Path -Path $powerShellDir -ChildPath 'Modules'
    $moduleDir = Join-Path -Path $modulesDir -ChildPath 'SecretManagement.Keybase'

    if (Test-Path -Path $moduleDir) {
        Remove-Item $moduleDir -Force -Recurse
    }

    New-Item -Path $moduleDir -ItemType Directory | Out-Null

    Copy-Item -Path .\src\* -Destination $moduleDir -Recurse -Force
}

Task RemoveModule {
    if (Get-Module -Name SecretManagement.Keybase) {
        Remove-Module -Name SecretManagement.Keybase
    }
}