function Register-KeybaseSecretVault {
    [CmdletBinding(DefaultParameterSetName = 'WithoutTeam')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'WithoutTeam')]
        [Parameter(Mandatory = $true, ParameterSetName = 'WithTeam')]
        [string]
        $Name,
        [Parameter(Mandatory = $true, ParameterSetName = 'WithoutTeam')]
        [Parameter(Mandatory = $true, ParameterSetName = 'WithTeam')]
        [string]
        $Namespace ,
        [Parameter(Mandatory = $true, ParameterSetName = 'WithTeam')]
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

        Register-SecretsVault -Name $Name -ModuleName 'SecretManagement.Keybase' -VaultParameters $vaultParameters

    }
    
    end {
        
    }
}