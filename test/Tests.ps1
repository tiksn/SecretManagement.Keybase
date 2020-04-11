Set-StrictMode -Version Latest

Describe 'Get-Secret' {
}

Describe 'Set-Secret' {
    BeforeAll {
        . .\test\Helpers.ps1
        CommonBeforeAll
    }
    AfterAll {
        . .\test\Helpers.ps1
        CommonAfterAll
    }

    It 'For string' {
        $name = "Name-$(Get-Random)"
        $secret = "Secret-$(Get-Random)"
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName
    }
}

Describe 'Remove-Secret' {
}

Describe 'Get-SecretInfo' {
}

Describe 'Test-SecretVault' {
}