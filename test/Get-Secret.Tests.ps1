Set-StrictMode -Version Latest

Describe 'Get-Secret' {
    It 'For ByteArray' {
        
    }

    It 'For string' {
        $name = "Name-$(Get-Random)"
        $secret = "Secret-$(Get-Random)"
        Add-Secret -Name $name -Secret $secret -Vault $Script:VaultName
        $retrievedSecret = Get-Secret -Name $name -Vault $Script:VaultName -AsPlainText

        $secret | Should -Be $retrievedSecret
    }

    It 'For SecureString' {

    }

    It 'For PSCredential' {

    }

    It 'For Hashtable' {

    }
}