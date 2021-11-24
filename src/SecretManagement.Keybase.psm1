function Register-KeybaseSecretVault {
    [CmdletBinding(DefaultParameterSetName = 'WithoutTeam')]
    param (
        [Parameter(ParameterSetName = 'WithoutTeam')]
        [Parameter(ParameterSetName = 'WithTeam')]
        [string]
        $SecretVault,
        [Parameter(ParameterSetName = 'WithoutTeam')]
        [string]
        $Namespace ,
        [Parameter(ParameterSetName = 'WithTeam')]
        [string]
        $Team
    )
    
    begin {
        
    }
    
    process {
        $vaultParameters = @{ 
            namespace = $Namespace
            team      = $Team
        }

        Register-SecretsVault -Name $SecretVault -ModuleName 'SecretManagement.Keybase' -VaultParameters $vaultParameters

    }
    
    end {
        
    }
}