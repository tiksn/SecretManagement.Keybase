Task PublishPSGallery -depends PublishLocally {

}

Task PublishLocally -depends Test {
    $documentsDir = [Environment]::GetFolderPath("MyDocuments")
    $powerShellDir = Join-Path -Path $documentsDir -ChildPath 'PowerShell'
    $modulesDir = Join-Path -Path $powerShellDir -ChildPath 'Modules'
    $moduleDir = Join-Path -Path $modulesDir -ChildPath 'KeybaseSecretManagementExtension'

    if (! (Test-Path -Path $moduleDir)) {
        New-Item -Path $moduleDir -ItemType Directory | Out-Null
    }

    Copy-Item -Path .\src\* -Destination $moduleDir -Recurse
}

Task Test -Depends ImportModule {
    Invoke-Pester -Script .\Tests.ps1
}
 
Task ImportModule -Depends RemoveModule {
    Import-Module .\src\KeybaseSecretManagementExtension.psd1
    
    if (!(Get-Module -Name KeybaseSecretManagementExtension)) {
        throw 'Failed to import module.'
    }
}
 
Task RemoveModule {
    if (Get-Module -Name KeybaseSecretManagementExtension) {
        Remove-Module -Name KeybaseSecretManagementExtension
    }
}