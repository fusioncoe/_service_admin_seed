# OnFusionCoE Setup Scripts

This directory contains helper scripts to streamline the configuration of your OnFusionCoE Service Admin repository.

## Available Scripts

### Set-OnFusionCoEConfig.ps1

PowerShell script to automate the complete setup process.

**Status:** ✅ Fully Implemented

**Purpose:**

- Create or configure Azure/Entra ID app registration
- Set up required API permissions (Microsoft Graph + Power Platform)
- Register app as Power Platform Management App
- Generate client secrets with configurable expiration
- Configure GitHub repository variables and secrets
- Support multiple Azure clouds (Public, GCC, GCC High, DoD)

**Prerequisites:**

- PowerShell 7.0+ (or Windows PowerShell 5.1+)
- Appropriate permissions:
  - Entra ID: Ability to create app registrations and grant admin consent (no Azure subscription required)
  - Power Platform: Power Platform admin permissions
  - GitHub: Repository admin access

**PowerShell Modules** (automatically installed by the script if missing):
- `Microsoft.Graph.Authentication` (version 2.0.0+)
- `Microsoft.Graph.Applications` (version 2.0.0+)
- `Microsoft.PowerApps.Administration.PowerShell`
- `Microsoft.PowerApps.PowerShell`

**Optional** (for GitHub configuration):
- GitHub CLI (`gh`) - If not installed, you can provide a GitHub Personal Access Token instead

**Important:** The Power Platform Management App registration requires **USER credentials**, not service principal authentication. You will be prompted to sign in interactively during the script execution.

> **Note:** You do NOT need to install the PowerShell modules manually. The script will automatically detect and install any missing modules when you run it.

**Installation:**

> **You can skip this section!** The script automatically installs missing modules for you.

If you prefer to install modules manually before running the script:

```powershell
# Install required Microsoft Graph modules
Install-Module -Name Microsoft.Graph.Authentication -MinimumVersion 2.0.0 -Scope CurrentUser
Install-Module -Name Microsoft.Graph.Applications -MinimumVersion 2.0.0 -Scope CurrentUser

# Install Power Platform modules (for Management App registration)
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber -Scope CurrentUser

# Install GitHub CLI (optional but recommended)
winget install GitHub.cli
```

**Recommendation:** Just run the script directly. It will install what's needed.

**Usage:**

> **No setup required!** The script will automatically check for and install any missing PowerShell modules.

```powershell
# Interactive mode (recommended for first-time setup)
.\Set-OnFusionCoEConfig.ps1

# Automated mode with parameters
.\Set-OnFusionCoEConfig.ps1 `
    -TenantId "your-tenant-id" `
    -GitHubOrg "your-github-org" `
    -GitHubRepo "_service_admin_seed" `
    -Cloud "Public"

# Use existing app registration
.\Set-OnFusionCoEConfig.ps1 `
    -ApplicationId "existing-app-id" `
    -SkipPermissions `
    -GitHubOrg "your-github-org"
```

**Parameters:**

| Parameter | Required | Description | Default |
|-----------|----------|-------------|---------|
| `TenantId` | No* | Azure tenant ID | Interactive prompt |
| `ApplicationId` | No | Existing app ID (skips creation) | Creates new |
| `ApplicationName` | No | Name for new app registration | `OnFusionCoE-ServicePrincipal` |
| `GitHubOrg` | No* | GitHub organization name | Interactive prompt |
| `GitHubRepo` | No | GitHub repository name | `_service_admin_seed` |
| `GitHubToken` | No | GitHub PAT (or uses `gh` CLI) | Uses GitHub CLI |
| `Cloud` | No | Cloud environment (`Public`, `GCC`, `GCC High`, `DoD`) | `Public` |
| `SkipPermissions` | No | Skip API permission setup | `false` |
| `SkipPowerPlatformRegistration` | No | Skip PP Management App registration | `false` |
| `SkipGitHub` | No | Skip GitHub configuration | `false` |
| `SecretExpirationMonths` | No | Months until secret expires (1-24) | `12` |

*Required if not running interactively

**Examples:**

```powershell
# Create everything from scratch (interactive)
.\Set-OnFusionCoEConfig.ps1

# Create everything with parameters (automated)
.\Set-OnFusionCoEConfig.ps1 `
    -TenantId "12345678-90ab-cdef-1234-567890abcdef" `
    -GitHubOrg "contoso" `
    -Cloud "Public"

# Use existing app, only configure GitHub
.\Set-OnFusionCoEConfig.ps1 `
    -ApplicationId "a1b2c3d4-e5f6-7890-abcd-ef1234567890" `
    -TenantId "12345678-90ab-cdef-1234-567890abcdef" `
    -GitHubOrg "contoso" `
    -SkipPermissions `
    -SkipPowerPlatformRegistration

# Government cloud setup (GCC)
.\Set-OnFusionCoEConfig.ps1 `
    -TenantId "12345678-90ab-cdef-1234-567890abcdef" `
    -GitHubOrg "contoso" `
    -Cloud "GCC"

# GCC High setup
.\Set-OnFusionCoEConfig.ps1 `
    -TenantId "12345678-90ab-cdef-1234-567890abcdef" `
    -GitHubOrg "contoso" `
    -Cloud "GCC High"

# DoD cloud setup
.\Set-OnFusionCoEConfig.ps1 `
    -TenantId "12345678-90ab-cdef-1234-567890abcdef" `
    -GitHubOrg "contoso" `
    -Cloud "DoD"

# Generate configuration only (don't update GitHub)
.\Set-OnFusionCoEConfig.ps1 `
    -TenantId "12345678-90ab-cdef-1234-567890abcdef" `
    -SkipGitHub

# Custom secret expiration (6 months)
.\Set-OnFusionCoEConfig.ps1 `
    -TenantId "12345678-90ab-cdef-1234-567890abcdef" `
    -GitHubOrg "contoso" `
    -SecretExpirationMonths 6

# Skip Power Platform registration (configure manually later)
.\Set-OnFusionCoEConfig.ps1 `
    -TenantId "12345678-90ab-cdef-1234-567890abcdef" `
    -GitHubOrg "contoso" `
    -SkipPowerPlatformRegistration
```

### register-pp-spn.ps1

Original standalone script for Power Platform service principal registration.

**Status:** ✅ Available (integrated into Set-OnFusionCoEConfig.ps1)

**Purpose:**

- Register an existing app as a Power Platform Management App
- Check for existing management app registrations
- Support multiple cloud environments

**Usage:**

```powershell
.\register-pp-spn.ps1
```

This script is now integrated into `Set-OnFusionCoEConfig.ps1`. You can still use it standalone if you only need to perform Power Platform registration without full setup.

**Note:** This script requires interactive user authentication and cannot use service principal credentials.

## Manual Setup

If you prefer to configure manually or the script doesn't meet your needs, follow the detailed instructions in [docs/SETUP.md](../docs/SETUP.md).

## Future Scripts

Additional helper scripts may be added for:

- Configuration validation and testing
- Secret rotation automation
- Bulk environment setup
- Permission auditing

## Contributing

If you develop custom scripts for your organization, consider contributing them back to help other OnFusionCoE users.

## Support

For issues with these scripts:

1. Review the [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)
2. Check script output for specific error messages
3. Verify prerequisites are installed and up-to-date
4. Contact your OnFusionCoE administrator

---

**Last Updated:** November 12, 2025
