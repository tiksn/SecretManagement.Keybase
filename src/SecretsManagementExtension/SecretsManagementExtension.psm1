function ConvertTo-MultiformatString {
    param (
        [Parameter(Mandatory = $false)]
        [object]
        $EntryValue
    )

    if ($null -eq $EntryValue) {
        throw 'Secret cannot be null'
    }

    $valueSet = @{ }
    switch ($EntryValue) {
        { $EntryValue -is [string] } {
            $valueSet.Add('string', $EntryValue)
            break
        }
        { $EntryValue -is [byte[]] } {
            $valueSet.Add('bytes', [Convert]::ToBase64String($EntryValue))
            break 
        }
        {$EntryValue -is [Hashtable]} {
            $valueSet.Add('hashtable', $EntryValue)
            break
        }
        default { throw 'type is not supported' }
    }
    $valueSetJson = $valueSet | ConvertTo-Json -Depth 2 -Compress
    return $valueSetJson
}

function ConvertFrom-MultiformatString {
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

    $request = @{ 'method' = $Method; 'params' = @{'options' = $requestOptions } }
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

    if ([WildcardPattern]::ContainsWildcardCharacters($Name))
    {
        throw "The Name parameter cannot contain wild card characters."
    }
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
