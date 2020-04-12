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
        { $EntryValue -is [Hashtable] } {
            $valueSet.Add('hashtable', $EntryValue)
            break
        }
        default {
            Write-Error 'Type serialization is not supported'
            return 
        }
    }
    $valueSetJson = $valueSet | ConvertTo-Json -Depth 2 -Compress
    return $valueSetJson
}

function ConvertFrom-MultiformatString {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Value
    )

    $valueSet = $Value | ConvertFrom-Json -Depth 2 -AsHashtable
    if ($valueSet.Keys.Count -ne 1) {
        Write-Error 'Value set must contain only 1 value'
        return
    }
    switch ($valueSet.Keys[0]) {
        'string' { 
            return $valueSet.Values[0]
        }
        'bytes' {
            $secret = [Convert]::FromBase64String($valueSet.Values[0])
            return [byte[]] $secret
        }
        'hashtable' { 
            return $valueSet.Values[0]
        }
        default {
            Write-Error 'Type deserialization is not supported'
            return
        }
    }
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

    if ([WildcardPattern]::ContainsWildcardCharacters($Name)) {
        throw "The Name parameter cannot contain wild card characters."
    }

    $result = Invoke-ApiCall -Method 'get' -AdditionalParameters $AdditionalParameters -EntryKey $Name

    if ($null -eq $result.result.entryValue) {
        return
    }

    $entryValue = ConvertFrom-MultiformatString -Value $result.result.entryValue

    if ($entryValue.GetType().IsArray) {
        return @(, [byte[]] $entryValue)
    }

    return $entryValue
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
