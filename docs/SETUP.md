# OnFusionCoE Service Admin Setup Guide

This guide provides detailed instructions for setting up and configuring your OnFusionCoE Service Admin repository.

## Recommended: Automated Setup Script

**We strongly recommend using the automated PowerShell script for setup.** The script handles all configuration steps including the critical Power Platform Management App registration.

### Quick Setup with Script

```powershell
# Navigate to the scripts directory
cd scripts

# Run the automated setup (interactive mode)
.\Set-OnFusionCoEConfig.ps1

# Or with parameters for automation
.\Set-OnFusionCoEConfig.ps1 -TenantId "your-tenant-id" -GitHubOrg "your-org" -Cloud "Public"
```

**What the script does:**
- ✅ **Automatically installs all required PowerShell modules** (no manual installation needed)
- ✅ Creates or configures Azure/Entra ID app registration
- ✅ Configures all required API permissions
- ✅ Registers as Power Platform Management App (with user authentication)
- ✅ Generates client secret with configurable expiration
- ✅ Configures GitHub repository variables and secrets
- ✅ Supports all cloud environments (Public, GCC, GCC High, DoD)

> **No setup required!** The script will automatically check for and install any missing PowerShell modules (Microsoft.Graph.Authentication, Microsoft.Graph.Applications, Microsoft.PowerApps modules) if they are not already present on your system.

**See [scripts/README.md](../scripts/README.md) for complete script documentation and examples.**

---

## Alternative: Manual Setup Steps

**If you prefer to configure manually** or need to understand each step in detail, follow the instructions below.

> **Note:** The manual steps below achieve the same result as the automated script. Choose manual setup only if you have specific requirements or prefer to configure each component yourself.

## Table of Contents

- [Recommended: Automated Setup Script](#recommended-automated-setup-script)
- [Alternative: Manual Setup Steps](#alternative-manual-setup-steps)
- [Prerequisites](#prerequisites)
- [Manual Step 1: Create Azure/Entra ID App Registration](#manual-step-1-create-azureentra-id-app-registration)
- [Manual Step 2: Configure App Registration Permissions](#manual-step-2-configure-app-registration-permissions)
- [Manual Step 3: Create Client Secret](#manual-step-3-create-client-secret)
- [Manual Step 4: Configure Repository Variables and Secrets](#manual-step-4-configure-repository-variables-and-secrets)
- [Manual Step 5: Verify Configuration](#manual-step-5-verify-configuration)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites (Manual Setup)

> **Reminder:** You can skip these manual steps by using the automated script: `scripts\Set-OnFusionCoEConfig.ps1`

Before you begin manual setup, ensure you have:

- **OnFusionCoE GitHub Application** installed in your GitHub organization
- **Azure/Entra ID Admin Access** to create app registrations in your target tenant
- **Power Platform Admin Access** in the environment where development will occur
- **GitHub Repository Admin Access** to configure secrets and variables

---

## Manual Step 1: Create Azure/Entra ID App Registration

> **Automated Alternative:** The `Set-OnFusionCoEConfig.ps1` script creates the app registration automatically.

### Manual Steps:

1. Sign in to the [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** (or **Microsoft Entra ID**)
3. Select **App registrations** from the left menu
4. Click **+ New registration**
5. Configure the registration:
   - **Name:** `OnFusionCoE-ServicePrincipal` (or your preferred name)
   - **Supported account types:** Select based on your organizational needs
     - Single tenant (recommended for most scenarios)
   - **Redirect URI:** Leave blank for now
6. Click **Register**

### Collect Required Information

After creation, collect the following from the **Overview** page:

- **Application (client) ID** - You'll use this for `FUSIONCOE_SP_APPLICATION_ID`
- **Directory (tenant) ID** - You'll use this for `FUSIONCOE_SP_TENANT_ID`

---

## Manual Step 2: Configure App Registration Permissions

> **Automated Alternative:** The `Set-OnFusionCoEConfig.ps1` script configures all permissions automatically.

The service principal needs appropriate API permissions to manage Power Platform and Entra ID resources.

### Required API Permissions (Manual Configuration)

> **Important:** Configuring API permissions alone is not sufficient. You must also register the app as a Power Platform Management App (see Step 2.1 below) to enable provisioning of Power Platform resources.

1. In your app registration, select **API permissions** from the left menu
2. Click **+ Add a permission**
3. Add the following permissions:

#### Microsoft Graph

- **Application.ReadWrite.All** (Application) - Manage app registrations
- **Group.ReadWrite.All** (Application) - Manage security groups
- **User.Read.All** (Application) - Read user information

#### Power Platform API

- **Tenant.ReadWrite.All** (Application) - Manage Power Platform environments

#### Dynamics CRM (if applicable)

- **user_impersonation** (Delegated) - Access Dataverse as organization users

### Grant Admin Consent

1. After adding permissions, click **Grant admin consent for [Your Tenant]**
2. Confirm the consent prompt

### Manual Step 2.1: Register as Power Platform Management App

> **Automated Alternative:** The `Set-OnFusionCoEConfig.ps1` script handles this registration with interactive user authentication.

**CRITICAL:** In addition to API permissions, the service principal must be registered as a Power Platform Management App to enable provisioning of Power Platform resources such as environments, Dataverse databases, and Power Automate connections.

This registration **cannot** be done through the Azure Portal and requires PowerShell with **USER credentials** (not service principal credentials).

**Prerequisites:**
- PowerShell modules:
  - `Microsoft.PowerApps.Administration.PowerShell`
  - `Microsoft.PowerApps.PowerShell`
- User account with Power Platform admin permissions
- The Application ID from your app registration

**Steps:**

1. Install required modules if not already installed:

```powershell
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber -Scope CurrentUser
```

2. Connect to Power Platform (choose your cloud):

```powershell
# For Commercial Cloud
Add-PowerAppsAccount -Endpoint prod -TenantID "your-tenant-id"

# For GCC
Add-PowerAppsAccount -Endpoint usgov -TenantID "your-tenant-id"

# For GCC High
Add-PowerAppsAccount -Endpoint usgovhigh -TenantID "your-tenant-id"

# For DoD
Add-PowerAppsAccount -Endpoint dod -TenantID "your-tenant-id"
```

3. Check for existing management apps (optional):

```powershell
Get-PowerAppManagementApps
```

4. Register your application:

```powershell
New-PowerAppManagementApp -ApplicationId "your-application-id"
```

**Important Notes:**
- You will be prompted to sign in with your **user account** (service principals cannot be used)
- Your user must have Power Platform administrator permissions
- Without this registration, OnFusionCoE workflows will fail when attempting to provision environments or connections
- This is a one-time registration per application

**Reference:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

Alternatively, use the provided `Set-OnFusionCoEConfig.ps1` script which automates this entire process.

---

## Manual Step 3: Create Client Secret

> **Automated Alternative:** The `Set-OnFusionCoEConfig.ps1` script generates the client secret with configurable expiration.

1. In your app registration, select **Certificates & secrets** from the left menu
2. Under **Client secrets**, click **+ New client secret**
3. Configure the secret:
   - **Description:** `OnFusionCoE Service Secret`
   - **Expires:** Choose based on your security policy (e.g., 12 months, 24 months)
4. Click **Add**
5. **IMPORTANT:** Copy the secret **Value** immediately - you won't be able to see it again
   - This will be used for `FUSIONCOE_SP_SECRET`

### Security Best Practices

- Store the client secret securely (password manager, key vault, etc.)
- Never commit the secret to source control
- Set a calendar reminder to rotate the secret before expiration
- Use the shortest expiration period that meets your operational needs

---

## Manual Step 4: Configure Repository Variables and Secrets

> **Automated Alternative:** The `Set-OnFusionCoEConfig.ps1` script configures GitHub variables and secrets automatically (using GitHub CLI or API).

OnFusionCoE automatically creates placeholder variables and secrets in your repository. You need to populate them with the values from your app registration.

### Configure Variables (Manual)

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab
3. Update the following variables:

| Variable Name | Value | Example |
|---------------|-------|---------|
| `FUSIONCOE_SP_APPLICATION_ID` | Application (client) ID from Step 1 | `a1b2c3d4-e5f6-7890-abcd-ef1234567890` |
| `FUSIONCOE_SP_TENANT_ID` | Directory (tenant) ID from Step 1 | `12345678-90ab-cdef-1234-567890abcdef` |
| `FUSIONCOE_SP_AUTHORITY` | Azure AD authority URL | `https://login.microsoftonline.com/` |
| `FUSIONCOE_SP_CLOUD` | Target cloud environment | `Public` (or `GCC`, `GCC High`, `DoD`) |

### Configure Secrets

1. Go to **Settings** → **Secrets and variables** → **Actions** → **Secrets** tab
2. Update the following secrets:

| Secret Name | Value | Source |
|-------------|-------|--------|
| `FUSIONCOE_SP_SECRET` | Client secret value from Step 3 | Azure App Registration |
| `FUSIONCOE_SP_PRIVATE_KEY` | Private key for workflow output authentication | Automatically managed by OnFusionCoE |

> **Note:** The `FUSIONCOE_SP_PRIVATE_KEY` is automatically created and rotated daily by the OnFusionCoE service. This key is part of a cryptographic signing mechanism that authenticates workflow outputs sent back to the service, ensuring data integrity and verifying the output originates from your repository. No manual configuration is required - if the secret is missing or outdated, contact your OnFusionCoE administrator.

### Cloud Environment Values

Choose the appropriate cloud value based on your deployment:

- `Public` - Commercial Azure cloud
- `GCC` - Government Community Cloud
- `GCC High` - Government Community Cloud High
- `DoD` - Department of Defense cloud

---

## Manual Step 5: Verify Configuration

> **Automated Alternative:** The `Set-OnFusionCoEConfig.ps1` script provides a verification summary upon completion.

After configuration, verify everything is set up correctly:

### Check Variables and Secrets

1. Navigate to **Settings** → **Secrets and variables** → **Actions**
2. Verify all 4 variables are configured (Values tab)
3. Verify all 2 secrets are configured (Secrets tab) - you'll see names but not values

### Test Authentication (Optional)

The OnFusionCoE service will automatically test the configuration when it first attempts to use the workflows. Monitor the **Actions** tab for any workflow runs and check for authentication errors.

---

## Automated Setup Script (Recommended)

**Instead of following the manual steps above**, we recommend using the automated PowerShell script for a faster, more reliable setup experience.

## Using the PowerShell Helper Script

The PowerShell script `Set-OnFusionCoEConfig.ps1` automates the entire configuration process, including Power Platform Management App registration.

### Prerequisites for Script

- PowerShell 7.0 or later (recommended) or Windows PowerShell 5.1
- Microsoft Graph PowerShell modules (`Microsoft.Graph.Authentication`, `Microsoft.Graph.Applications`)
- Power Platform PowerShell modules (`Microsoft.PowerApps.Administration.PowerShell`, `Microsoft.PowerApps.PowerShell`)
- GitHub CLI (`gh`) or a GitHub Personal Access Token

**The script will automatically install missing modules.** No Azure subscription is required - only Entra ID permissions.

### Running the Script

```powershell
# Navigate to the scripts directory
cd scripts

# Run the setup script (interactive mode - RECOMMENDED)
.\Set-OnFusionCoEConfig.ps1

# Or with parameters for automation
.\Set-OnFusionCoEConfig.ps1 -TenantId "your-tenant-id" -GitHubOrg "your-org" -Cloud "Public"

# For government clouds
.\Set-OnFusionCoEConfig.ps1 -TenantId "your-tenant-id" -GitHubOrg "your-org" -Cloud "GCC"
```

### What the Script Does (Automated)

The script will:

1. Prompt you for necessary information (or use provided parameters)
2. Create the Azure app registration (if needed)
3. Configure required API permissions
4. Create a client secret
5. **Register as Power Platform Management App** (with user authentication)
6. Update GitHub repository variables and secrets

**Important:** The script will prompt you to authenticate with your **user credentials** when registering the Power Platform Management App. This cannot be automated with service principal credentials.

See the [scripts/README.md](../scripts/README.md) file for detailed usage instructions and parameters.

**Reference:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

## Troubleshooting

> **Note:** Many common issues are automatically handled by the `Set-OnFusionCoEConfig.ps1` script. Consider using the script if you encounter problems with manual setup.

### Common Issues

#### "Unauthorized" or "Insufficient privileges" errors

**Problem:** The service principal doesn't have necessary permissions.

**Solution:**
- Verify all API permissions are granted in Azure
- Ensure admin consent has been granted
- Confirm the service principal has appropriate Power Platform admin roles

#### "Invalid client secret" errors

**Problem:** The client secret is incorrect or expired.

**Solution:**
- Verify you copied the secret value (not the secret ID)
- Check if the secret has expired in Azure
- Generate a new secret and update `FUSIONCOE_SP_SECRET`

#### Workflows not triggering

**Problem:** OnFusionCoE service cannot trigger workflows.

**Solution:**
- Verify the OnFusionCoE GitHub App is installed in your organization
- Check that the app has access to this repository
- Ensure repository is not archived

#### "Invalid authority" errors

**Problem:** The authority URL is incorrect for your cloud.

**Solution:**
- Verify `FUSIONCOE_SP_AUTHORITY` matches your cloud:
  - Public: `https://login.microsoftonline.com/`
  - GCC: `https://login.microsoftonline.us/`
  - GCC High/DoD: Contact your cloud administrator

### Getting Help

If you continue to experience issues:

1. Review workflow run logs in the **Actions** tab
2. Check the [Troubleshooting Guide](./TROUBLESHOOTING.md)
3. Contact your OnFusionCoE service administrator
4. Review Azure AD sign-in logs for authentication failures

## Security Considerations

- **Rotate secrets regularly** - Set up a reminder to rotate client secrets before expiration
- **Use principle of least privilege** - Only grant permissions necessary for your use cases
- **Monitor usage** - Regularly review Azure AD sign-in logs and audit logs
- **Protect this repository** - Use branch protection and require reviews for changes
- **Never commit secrets** - Secrets should only exist in GitHub Secrets, never in code

## Next Steps

After completing setup:

1. Review the [Workflow Reference](./WORKFLOWS.md) to understand available operations
2. Monitor the **Actions** tab for workflow executions
3. Set up calendar reminders for secret rotation
4. Document any custom configurations for your team

---

**Last Updated:** November 12, 2025
