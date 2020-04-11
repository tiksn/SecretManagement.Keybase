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