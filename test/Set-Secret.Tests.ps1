Set-StrictMode -Version Latest

Describe 'Set-Secret' {
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
    }

    It 'For string' {
        $name = "Name-$(Get-Random)"
        $secret = "Secret-$(Get-Random)"
        Set-Secret -Name $name -Secret $secret -Vault $VaultName
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
        Set-Secret -Name $name -Secret $secret -Vault $VaultName
    }
}