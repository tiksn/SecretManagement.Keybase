@{
    ModuleVersion = '1.0.0'
    RootModule = '.\SecretsManagementExtension.psm1'
    FunctionsToExport = @('Set-Secret','Get-Secret','Remove-Secret','Get-SecretInfo','Test-SecretVault')
}
