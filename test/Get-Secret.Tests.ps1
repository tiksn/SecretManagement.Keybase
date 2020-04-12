Set-StrictMode -Version Latest

Describe 'Get-Secret' {
    BeforeAll {
        . .\test\Helpers.ps1
        CommonBeforeAll
    }
    AfterAll {
        . .\test\Helpers.ps1
        CommonAfterAll
    }

    It 'For ByteArray' {
        $name = "Name-$(Get-Random)"

        $bufferSize = 2048
        $buffer = [System.Byte[]]::new($bufferSize)
        $random = [System.Random]::new()
        $random.NextBytes($buffer)
        $secret = $buffer
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName
        $retrievedSecret = Get-Secret -Name $name -Vault $Script:VaultName

        $retrievedSecret | Should -Be $secret
    }

    It 'For string' {
        $name = "Name-$(Get-Random)"
        $secret = "Secret-$(Get-Random)"
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName
        $retrievedSecret = Get-Secret -Name $name -Vault $Script:VaultName -AsPlainText

        $retrievedSecret | Should -Be $secret
    }

    It 'For SecureString' {

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
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName
        $retrievedSecret = Get-Secret -Name $name -Vault $Script:VaultName

        $retrievedSecret | Should -Not -BeNullOrEmpty
        
        foreach ($key in $secret.Keys) {
            $retrievedSecret[$key] | Should -Be $secret[$key]
        }
    }
}