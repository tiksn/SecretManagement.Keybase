Set-StrictMode -Version Latest

Describe 'Get-Secret' {
    BeforeAll {
        . .\test\Helpers.ps1
        . CommonBeforeAll
    }
    AfterAll {
        . .\test\Helpers.ps1
        . CommonAfterAll
    }

    It 'For ByteArray' {
        $name = "Name-$(Get-Random)"

        $bufferSize = 2048
        $buffer = [System.Byte[]]::new($bufferSize)
        $random = [System.Random]::new()
        $random.NextBytes($buffer)
        $secret = $buffer
        Set-Secret -Name $name -Secret $secret -Vault $VaultName
        $retrievedSecret = Get-Secret -Name $name -Vault $VaultName

        $retrievedSecret | Should -Be $secret
    }

    It 'For string' {
        $name = "Name-$(Get-Random)"
        $secret = "Secret-$(Get-Random)"
        Set-Secret -Name $name -Secret $secret -Vault $VaultName
        $retrievedSecret = Get-Secret -Name $name -Vault $VaultName -AsPlainText

        $retrievedSecret | Should -Be $secret
    }

    It 'For SecureString' {
        $name = "Name-$(Get-Random)"
        $plainTextSecret = "Secret-$(Get-Random)"
        $secret = ConvertTo-SecureString -String $plainTextSecret -AsPlainText
        Set-Secret -Name $name -SecureStringSecret $secret -Vault $VaultName
        $retrievedSecret = Get-Secret -Name $name -Vault $VaultName -AsPlainText

        $retrievedSecret | Should -Be $plainTextSecret
    }

    It 'For PSCredential' {

    }

    It 'For Hashtable' {
        $name = "Name-$(Get-Random)"
        $secret = @{
            "Key-$(Get-Random)" = "Value-$(Get-Random)"
            "Key-$(Get-Random)" = "Value-$(Get-Random)"
            "Key-$(Get-Random)" = "Value-$(Get-Random)"
        }
        Set-Secret -Name $name -Secret $secret -Vault $VaultName
        $retrievedSecret = Get-Secret -Name $name -Vault $VaultName -AsPlainText

        $retrievedSecret | Should -Not -BeNullOrEmpty

        foreach ($key in $secret.Keys) {
            $retrievedSecret[$key] | Should -Be $secret[$key]
        }
    }
}