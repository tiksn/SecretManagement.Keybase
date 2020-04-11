
function CommonBeforeAll {
    param (
    )
    $randomNumber = Get-Random
    $Script:VaultName = "KeybaseSecretManagementExtension-$randomNumber"
    $vaultParameters = @{ }
    $vaultParameters.Add("Key-$(Get-Random)", "Value-$(Get-Random)")
    Register-SecretsVault -Name $Script:VaultName -ModuleName 'KeybaseSecretManagementExtension' -VaultParameters $vaultParameters
}

function CommonAfterAll {
    param (
    )
    Unregister-SecretsVault -Name $Script:VaultName
}