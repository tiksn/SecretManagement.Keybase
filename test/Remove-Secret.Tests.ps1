Set-StrictMode -Version Latest

Describe 'Remove-Secret' {
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
        Remove-Secret -Name $name -Vault $VaultName
    }

    It 'For string' {
        $name = "Name-$(Get-Random)"
        $secret = "Secret-$(Get-Random)"
        Set-Secret -Name $name -Secret $secret -Vault $VaultName
        Remove-Secret -Name $name -Vault $VaultName
    }

    It 'For SecureString' {
        $name = "Name-$(Get-Random)"
        $plainTextSecret = "Secret-$(Get-Random)"
        $secret = ConvertTo-SecureString -String $plainTextSecret -AsPlainText
        Set-Secret -Name $name -Secret $secret -Vault $VaultName
        Remove-Secret -Name $name -Vault $VaultName
    }

    It 'For PSCredential' {
        $name = "Name-$(Get-Random)"
        $userName = "UserName-$(Get-Random)"
        $plainTextPassword = "Password-$(Get-Random)"
        $protectedPassword = ConvertTo-SecureString -String $plainTextPassword -AsPlainText
        [pscredential]$secretCredential = New-Object System.Management.Automation.PSCredential ($userName, $protectedPassword)
        Set-Secret -Name $name -Secret $secretCredential -Vault $VaultName
        Remove-Secret -Name $name -Vault $VaultName
    }

    It 'For Hashtable' {
        $name = "Name-$(Get-Random)"
        $secret = @{
            "Key-$(Get-Random)" = "Value-$(Get-Random)"
            "Key-$(Get-Random)" = "Value-$(Get-Random)"
            "Key-$(Get-Random)" = "Value-$(Get-Random)"
        }
        Set-Secret -Name $name -Secret $secret -Vault $VaultName
        Remove-Secret -Name $name -Vault $VaultName
    }
}