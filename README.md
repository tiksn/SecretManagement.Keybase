# Keybase Secret Management Extension for PowerShell

![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/SecretManagement.Keybase)

Secret Management Extension for [PowerShell Secrets Management](https://www.powershellgallery.com/packages/Microsoft.PowerShell.SecretsManagement/) using [Keybase](https://keybase.io/) KV store as a Vault.

Check out package in [PS Gallery](https://www.powershellgallery.com/packages/SecretManagement.Keybase/).

```PowerShell
Install-Module -Name SecretManagement.Keybase
```

Usage

```PowerShell
Register-KeybaseSecretVault -Name 'VaultName' -Namespace 'NamespaceName'
```

Or

```PowerShell
Register-KeybaseSecretVault -Name 'VaultName' -Namespace 'NamespaceName' -Team 'TeamName'
```

## Secret type support

- [X] ByteArray
- [X] String
- [X] SecureString
- [X] PSCredential
- [X] Hashtable