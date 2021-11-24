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
        if ($Team) {
            $vaultParameters = @{ 
                namespace = $Namespace
                team      = $Team
            }
        }
        else {
            $vaultParameters = @{ 
                namespace = $Namespace
            }
        }
        Register-SecretVault -Name $Name -ModuleName 'SecretManagement.Keybase' -VaultParameters $vaultParameters
    }
    
    end {
        
    }
}