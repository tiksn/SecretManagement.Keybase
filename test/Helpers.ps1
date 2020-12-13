
function CommonBeforeAll {
    param (
    )

    $randomNumber = Get-Random
    $VaultName = "SecretManagement.Keybase-$randomNumber"
    $vaultParameters = @{'namespace' = 'test' }
    $vaultParameters.Add("Key-$(Get-Random)", "Value-$(Get-Random)")
    Register-SecretVault -Name $VaultName -ModuleName 'SecretManagement.Keybase' -VaultParameters $vaultParameters
    $Vault = Get-SecretVault -Name $VaultName
    $Vault | Should -Not -Be $null
}

function CommonAfterAll {
    param (
    )

    Unregister-SecretVault -Name $VaultName
}