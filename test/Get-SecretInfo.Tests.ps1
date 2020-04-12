Set-StrictMode -Version Latest

Describe 'Get-SecretInfo' {
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
        $name = "Name-$(Get-Random)"
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName

        $secretInfo = Get-SecretInfo -Name $name -Vault $Script:VaultName

        $secretInfo | Should -Not -BeNullOrEmpty

        $secretInfo = Get-SecretInfo -Name 'name-*' -Vault $Script:VaultName

        $secretInfo | Should -Not -BeNullOrEmpty
    }

    It 'For string' {
        $name = "Name-$(Get-Random)"
        $secret = "Secret-$(Get-Random)"
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName
        $name = "Name-$(Get-Random)"
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName

        $secretInfo = Get-SecretInfo -Name $name -Vault $Script:VaultName

        $secretInfo | Should -Not -BeNullOrEmpty

        $secretInfo = Get-SecretInfo -Name 'name-*' -Vault $Script:VaultName

        $secretInfo | Should -Not -BeNullOrEmpty
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
        $name = "Name-$(Get-Random)"
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName

        $secretInfo = Get-SecretInfo -Name $name -Vault $Script:VaultName

        $secretInfo | Should -Not -BeNullOrEmpty

        $secretInfo = Get-SecretInfo -Name 'name-*' -Vault $Script:VaultName

        $secretInfo | Should -Not -BeNullOrEmpty
    }
}