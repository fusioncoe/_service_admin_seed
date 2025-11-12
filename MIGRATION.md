# Migration to Microsoft.Graph PowerShell Modules

## Overview

The OnFusionCoE Service Admin setup script has been refactored to use **Microsoft.Graph PowerShell modules** instead of Azure PowerShell (Az) modules. This change eliminates the requirement for an Azure subscription, as app registrations are tenant-level resources in Entra ID.

## Why This Change?

### Problem with Az Modules
- **Azure subscription dependency**: Az modules (Az.Accounts, Az.Resources) typically expect an Azure subscription ID
- **Unnecessary barrier**: Users managing only Entra ID resources (app registrations) don't necessarily have Azure subscriptions
- **Scope mismatch**: App registrations are tenant-level resources, not subscription-level resources

### Benefits of Microsoft.Graph Modules
- ✅ **No subscription required**: Works with just Entra ID tenant access
- ✅ **Tenant-level focus**: Designed specifically for Entra ID and Microsoft 365 management
- ✅ **Modern API**: Uses Microsoft Graph API (the modern standard)
- ✅ **Better cloud support**: Clearer distinction between cloud environments (Global, USGov, USGovDoD)
- ✅ **Granular permissions**: More precise control over required scopes

## What Changed

### PowerShell Modules

| Before (Az modules) | After (Microsoft.Graph modules) |
|---------------------|--------------------------------|
| Az.Accounts 2.0.0+ | Microsoft.Graph.Authentication 2.0.0+ |
| Az.Resources 5.0.0+ | Microsoft.Graph.Applications 2.0.0+ |

### Script Changes

#### 1. Module Requirements
```powershell
# Before
#Requires -Modules @{ ModuleName="Az.Accounts"; ModuleVersion="2.0.0" }
#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="5.0.0" }

# After
#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.0.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.0.0" }
```

#### 2. Cloud Environment Names
```powershell
# Before
Environment = "AzureCloud"        # Public cloud
Environment = "AzureUSGovernment" # GCC, GCC High, DoD

# After
Environment = "Global"      # Public cloud
Environment = "USGov"       # GCC
Environment = "USGovDoD"    # GCC High and DoD
```

#### 3. Authentication
```powershell
# Before
Connect-AzAccount -Environment $azureEnv -TenantId $TenantId
$context = Get-AzContext

# After
Connect-MgGraph -Environment $graphEnvironment -TenantId $TenantId -Scopes $scopes
$context = Get-MgContext
```

#### 4. App Registration Creation
```powershell
# Before
Get-AzADApplication -ApplicationId $ApplicationId
New-AzADApplication -DisplayName $ApplicationName

# After
Get-MgApplication -Filter "appId eq '$ApplicationId'"
New-MgApplication -DisplayName $ApplicationName -SignInAudience "AzureADMyOrg"
```

#### 5. Permission Configuration
```powershell
# Before
Update-AzADApplication -ObjectId $appRegistration.Id -RequiredResourceAccess $requiredResourceAccess

# After
$params = @{ RequiredResourceAccess = $requiredResourceAccess }
Update-MgApplication -ApplicationId $appRegistration.Id -BodyParameter $params
```

#### 6. Client Secret Creation
```powershell
# Before
New-AzADAppCredential -ObjectId $appRegistration.Id -EndDate $secretEndDate

# After
$passwordCredential = @{
    displayName = $secretName
    endDateTime = $secretEndDate
}
Add-MgApplicationPassword -ApplicationId $appRegistration.Id -PasswordCredential $passwordCredential
```

### Documentation Updates

All documentation has been updated to reflect the new modules:

- **README.md**: Clarified that no Azure subscription is required
- **docs/SETUP.md**: Updated prerequisites and manual setup instructions
- **docs/QUICKSTART.md**: Added automated setup section prominently
- **docs/TROUBLESHOOTING.md**: Updated authentication testing examples
- **scripts/README.md**: Changed all module references and installation commands

## For Users

### What You Need to Know

1. **No Azure subscription required**: You only need:
   - Entra ID tenant access
   - Permissions to create app registrations
   - Permissions to grant admin consent
   - Power Platform admin access (for Management App registration)

2. **Automatic module installation**: The script automatically installs Microsoft.Graph modules if they're not present

3. **Same functionality**: All features work exactly as before - only the underlying implementation changed

### Migration Path

If you previously installed Az modules manually, you can optionally remove them:

```powershell
# Optional: Remove old Az modules (only if not used by other scripts)
Uninstall-Module -Name Az.Accounts
Uninstall-Module -Name Az.Resources

# The new modules will be installed automatically by the script
```

### Running the Script

No changes to how you run the script:

```powershell
# Interactive mode (recommended)
.\scripts\Set-OnFusionCoEConfig.ps1

# With parameters
.\scripts\Set-OnFusionCoEConfig.ps1 -TenantId "your-tenant-id" -GitHubOrg "your-org" -Cloud "Public"
```

## Technical Details

### Required Microsoft Graph Scopes

The script requests these Graph API scopes:

- `Application.ReadWrite.All` - Create and manage app registrations
- `Directory.Read.All` - Read directory data

### Cloud Environment Mapping

| Cloud | Environment Name | Authority URL |
|-------|------------------|---------------|
| Commercial (Public) | Global | https://login.microsoftonline.com/ |
| GCC | USGov | https://login.microsoftonline.us/ |
| GCC High | USGovDoD | https://login.microsoftonline.us/ |
| DoD | USGovDoD | https://login.microsoftonline.us/ |

### Backward Compatibility

- **PowerShell version**: Still supports PowerShell 5.1+ and PowerShell 7.0+
- **Parameters**: All script parameters remain unchanged
- **GitHub integration**: No changes to GitHub configuration
- **Power Platform**: No changes to Power Platform Management App registration

## Benefits Summary

This refactoring provides:

1. **Broader accessibility**: Users without Azure subscriptions can now use the script
2. **Clearer requirements**: Focuses on actual needs (Entra ID access) rather than implied requirements (Azure subscription)
3. **Modern approach**: Uses Microsoft Graph API, the current standard for Microsoft cloud management
4. **Better isolation**: Separates Entra ID management from Azure resource management
5. **Improved documentation**: Clearer messaging about what's actually required

## Questions?

See the updated documentation:
- [SETUP.md](./docs/SETUP.md) - Detailed setup guide
- [scripts/README.md](./scripts/README.md) - Script documentation and parameters
- [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) - Common issues and solutions

---

**Last Updated**: November 12, 2025  
**Script Version**: 2.0.0
