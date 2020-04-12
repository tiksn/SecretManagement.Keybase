Set-StrictMode -Version Latest

Describe 'Test-SecretVault' {
    BeforeAll {
        . .\test\Helpers.ps1
        CommonBeforeAll
    }
    AfterAll {
        . .\test\Helpers.ps1
        CommonAfterAll
    }
}