Task PublishPSGallery -depends PublishLocally {
    if (Get-Module -Name KeybaseSecretManagementExtension) {
        Remove-Module -Name KeybaseSecretManagementExtension
    }

    Import-Module -Name KeybaseSecretManagementExtension

    $apiKey = Get-Secret -Name 'TIKSN-KeybaseSecretManagementExtension-PSGallery-ApiKey' -AsPlainText

    Publish-Module -Name KeybaseSecretManagementExtension -Repository PSGallery -NuGetApiKey $apiKey
}

Task Test -Depends ImportModule {
    $result = Invoke-Pester -Script .\test\Tests.ps1 -PassThru
    if ($result.FailedCount -ne 0) {
        throw 'Tests failed'
    }
}
 
Task ImportModule -Depends PublishLocally {
    Import-Module .\src\KeybaseSecretManagementExtension.psd1
    
    if (!(Get-Module -Name KeybaseSecretManagementExtension)) {
        throw 'Failed to import module.'
    }
}

Task PublishLocally -depends RemoveModule {
    $documentsDir = [Environment]::GetFolderPath("MyDocuments")
    $powerShellDir = Join-Path -Path $documentsDir -ChildPath 'PowerShell'
    $modulesDir = Join-Path -Path $powerShellDir -ChildPath 'Modules'
    $moduleDir = Join-Path -Path $modulesDir -ChildPath 'KeybaseSecretManagementExtension'

    if (Test-Path -Path $moduleDir) {
        Remove-Item $moduleDir -Force -Recurse
    }

    New-Item -Path $moduleDir -ItemType Directory | Out-Null

    Copy-Item -Path .\src\* -Destination $moduleDir -Recurse -Force
}

Task RemoveModule {
    if (Get-Module -Name KeybaseSecretManagementExtension) {
        Remove-Module -Name KeybaseSecretManagementExtension
    }
}