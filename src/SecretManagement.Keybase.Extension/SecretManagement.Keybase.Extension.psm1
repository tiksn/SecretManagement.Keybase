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
        [Parameter(Mandatory = $true)]
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
    $result = $resultJson | ConvertFrom-Json -Depth 4 -AsHashtable

    return $result
}

function Get-Secret {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $VaultName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable] $AdditionalParameters
    )

    if ($AdditionalParameters.Verbose) {
        $VerbosePreference = "Continue"
    }

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
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [object] $Secret,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $VaultName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable] $AdditionalParameters
    )

    if ($AdditionalParameters.Verbose) {
        $VerbosePreference = "Continue"
    }

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
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $VaultName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable] $AdditionalParameters
    )

    if ($AdditionalParameters.Verbose) {
        $VerbosePreference = "Continue"
    }

    $result = Invoke-ApiCall -Method 'del' -AdditionalParameters $AdditionalParameters -EntryKey $Name

    return $true
}

function Get-SecretInfo {
    [CmdletBinding()]
    param(
        [string] $Filter,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    if ($AdditionalParameters.Verbose) {
        $VerbosePreference = "Continue"
    }

    $listResult = Invoke-ApiCall -Method 'list' -AdditionalParameters $AdditionalParameters

    $pattern = [WildcardPattern]::Get($Filter, [System.Management.Automation.WildcardOptions]::IgnoreCase -bor [System.Management.Automation.WildcardOptions]::CultureInvariant)

    $listKeys = $listResult.result.entryKeys | Select-Object -ExpandProperty entryKey
    $listKeys = $listKeys | Where-Object { $pattern.IsMatch($_) }
    foreach ($listKey in $listKeys) {
        $result = Invoke-ApiCall -Method 'get' -AdditionalParameters $AdditionalParameters -EntryKey $listKey

        if ($null -eq $result.result.entryValue) {
            continue
        }

        $secret = ConvertFrom-MultiformatString -Value $result.result.entryValue
        $type = if ($secret.gettype().IsArray) { [Microsoft.PowerShell.SecretManagement.SecretType]::ByteArray }
        elseif ($secret -is [string]) { [Microsoft.PowerShell.SecretManagement.SecretType]::String }
        elseif ($secret -is [securestring]) { [Microsoft.PowerShell.SecretManagement.SecretType]::SecureString }
        elseif ($secret -is [PSCredential]) { [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential }
        elseif ($secret -is [hashtable]) { [Microsoft.PowerShell.SecretManagement.SecretType]::Hashtable }
        else { [Microsoft.PowerShell.SecretManagement.SecretType]::Unknown }

        Write-Output (
            [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
                $result.result.entryKey,
                $type,
                $VaultName
            )
        )
    }
}

function Test-SecretVault {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $VaultName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable] $AdditionalParameters
    )

    if ($AdditionalParameters.Verbose) {
        $VerbosePreference = "Continue"
    }

    $isValid = $true 

    if (-not $AdditionalParameters.ContainsKey('namespace')) {
        Write-Error '"namespace" additional parameters is required'
        $isValid = $false
    }

    return $isValid
}
