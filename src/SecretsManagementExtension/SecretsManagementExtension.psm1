function ConvertTo-MultiformatString {
    param (
        [Parameter(Mandatory = $false)]
        [object]
        $EntryValue
    )
    $EntryValue.ToString() #TODO: Replace with real implementation
}

function Invoke-ApiCall {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Method,
        [Parameter(Mandatory = $false)]
        [hashtable]
        $AdditionalParameters,
        [Parameter(Mandatory = $false)]
        [string]
        $EntryKey,
        [Parameter(Mandatory = $false)]
        [Nullable[int]]
        $Revision,
        [Parameter(Mandatory = $false)]
        [object]
        $EntryValue
    )
    
    $requestOptions = @{ }

    if ($AdditionalParameters.ContainsKey('team')) {
        $requestOptions.Add('team', $AdditionalParameters['team']);
    }

    if ($AdditionalParameters.ContainsKey('namespace')) {
        $requestOptions.Add('namespace', $AdditionalParameters['namespace']);
    }

    if ($null -ne $EntryKey) {
        $requestOptions.Add('entryKey', $EntryKey);
    }

    if ($null -ne $Revision) {
        $requestOptions.Add('revision', $Revision);
    }

    if ($null -ne $EntryValue) {
        $formattedValue = ConvertTo-MultiformatString -EntryValue $EntryValue
        $requestOptions.Add('entryValue', $formattedValue);
    }

    $request = @{ 'method' = $Method; 'params' = @{'options' = $requestOptions} }
    $json = $request | ConvertTo-Json
    $resultJson = $json | keybase kvstore api
    $result = $resultJson | ConvertFrom-Json -Depth 2 -AsHashtable

    return $result
}

function Get-Secret {
    param (
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
}

function Set-Secret {
    param (
        [string] $Name,
        [object] $Secret,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $result = Invoke-ApiCall -Method 'put' -AdditionalParameters $AdditionalParameters -EntryKey $Name -EntryValue $Secret

    if ($null -eq $result.error.message) {
        return $true
    }
    else {
        Write-Error $result.error.message
        return $false
    }
}

function Remove-Secret {
    param (
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
}

function Get-SecretInfo {
    param(
        [string] $Filter,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
}

function Test-SecretVault {
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
}
