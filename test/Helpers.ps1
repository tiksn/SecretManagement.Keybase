
function CommonBeforeAll {
    param (
    )

    $randomNumber = Get-Random
    $VaultName = "SecretManagement.Keybase-$randomNumber"
    Register-KeybaseSecretVault -Name $VaultName -Namespace 'test'
    $Vault = Get-SecretVault -Name $VaultName
    $Vault | Should -Not -Be $null
}

function CommonAfterAll {
    param (
    )

    Unregister-SecretVault -Name $VaultName
}