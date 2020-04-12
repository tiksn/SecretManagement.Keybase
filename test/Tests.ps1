Set-StrictMode -Version Latest

Describe 'Get-Secret' {
    It 'For ByteArray' {
        
    }

    It 'For string' {
    }

    It 'For SecureString' {

    }

    It 'For PSCredential' {

    }

    It 'For Hashtable' {

    }
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

    It 'For ByteArray' {
        
    }

    It 'For string' {
        $name = "Name-$(Get-Random)"
        $secret = "Secret-$(Get-Random)"
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName
    }

    It 'For SecureString' {
        
    }

    It 'For PSCredential' {
        
    }

    It 'For Hashtable' {
        
    }
}

Describe 'Remove-Secret' {
    It 'For ByteArray' {
        
    }

    It 'For string' {
    }

    It 'For SecureString' {
        
    }

    It 'For PSCredential' {
        
    }

    It 'For Hashtable' {
        
    }
}

Describe 'Get-SecretInfo' {
    It 'For ByteArray' {
        
    }

    It 'For string' {
    }

    It 'For SecureString' {
        
    }

    It 'For PSCredential' {
        
    }

    It 'For Hashtable' {
        
    }
}

Describe 'Test-SecretVault' {
}