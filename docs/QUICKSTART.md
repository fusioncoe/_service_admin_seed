# OnFusionCoE Quick Start Guide

Get your OnFusionCoE Service Admin repository configured in minutes.

## Prerequisites Checklist

- [ ] OnFusionCoE GitHub App installed in your organization
- [ ] Azure/Entra ID admin access
- [ ] Power Platform admin access
- [ ] GitHub repository admin access
- [ ] PowerShell (modules will be auto-installed if using the automated script)

## Automated Setup (Recommended - 5 Minutes)

**The easiest way to get started:**

```powershell
cd scripts
.\Set-OnFusionCoEConfig.ps1
```

The script automatically:
- ✅ Installs all required PowerShell modules
- ✅ Creates/configures app registration
- ✅ Sets up API permissions
- ✅ Registers Power Platform Management App
- ✅ Configures GitHub secrets

**See [scripts/README.md](../scripts/README.md) for parameters and advanced usage.**

---

## Manual Setup (5-10 Minutes)

If you prefer manual configuration, follow these steps:

> **Note:** First-time manual setup may take 10-15 minutes including module installation.

### Step 1: Create App Registration (2 minutes)

1. Go to [Azure Portal](https://portal.azure.com) → **Azure Active Directory** → **App registrations**
2. Click **+ New registration**
3. Name: `OnFusionCoE-ServicePrincipal`
4. Click **Register**
5. **Copy these values:**
   - Application (client) ID → `FUSIONCOE_SP_APPLICATION_ID`
   - Directory (tenant) ID → `FUSIONCOE_SP_TENANT_ID`

### Step 2: Add Permissions (1 minute)

1. In your app registration, go to **API permissions**
2. Add these permissions (click **+ Add a permission**):
   - **Microsoft Graph:**
     - Application.ReadWrite.All (Application)
     - Group.ReadWrite.All (Application)
     - User.Read.All (Application)
   - **Power Platform API:**
     - Tenant.ReadWrite.All (Application)
3. Click **Grant admin consent for [Your Tenant]**

> **Note:** API permissions alone are not enough - you must also complete Step 2.5 below!

### Step 2.5: Register Power Platform Management App (2 minutes)

**CRITICAL:** Without this step, the service cannot provision Power Platform resources!

1. Open PowerShell
2. Install modules (if needed):
   ```powershell
   Install-Module Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
   Install-Module Microsoft.PowerApps.PowerShell -AllowClobber -Scope CurrentUser
   ```
3. Connect and register:
   ```powershell
   # Connect (sign in with your USER account)
   Add-PowerAppsAccount -Endpoint prod -TenantID "your-tenant-id"
   
   # Register the app
   New-PowerAppManagementApp -ApplicationId "your-app-id-from-step-1"
   ```

**Important:** You must sign in with a **user account** (not service principal). Your user must have Power Platform admin permissions.

**Reference:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

### Step 3: Create Secret (1 minute)

1. Go to **Certificates & secrets** → **+ New client secret**
2. Description: `OnFusionCoE Service Secret`
3. Expiration: Choose based on your policy (12-24 months)
4. Click **Add**
5. **Copy the Value immediately** → `FUSIONCOE_SP_SECRET`

### Step 4: Configure GitHub (1 minute)

1. Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

2. **Update Variables (Variables tab):**
   - `FUSIONCOE_SP_APPLICATION_ID` = [Value from Step 1]
   - `FUSIONCOE_SP_TENANT_ID` = [Value from Step 1]
   - `FUSIONCOE_SP_AUTHORITY` = `https://login.microsoftonline.com/`
   - `FUSIONCOE_SP_CLOUD` = `Public`

3. **Update Secrets (Secrets tab):**
   - `FUSIONCOE_SP_SECRET` = [Value from Step 3]
   - `FUSIONCOE_SP_PRIVATE_KEY` = [Already provided by OnFusionCoE]

## Verification

1. Go to **Actions** tab in your repository
2. Wait for a workflow to trigger (or trigger manually if available)
3. Check that it completes successfully

## Cloud Variants

### Government Cloud (GCC)

Change these values:

- `FUSIONCOE_SP_AUTHORITY` = `https://login.microsoftonline.us/`
- `FUSIONCOE_SP_CLOUD` = `GCC`

### GCC High / DoD

Contact your cloud administrator for the correct authority URL.

- `FUSIONCOE_SP_CLOUD` = `GCC High` or `DoD`

## Common First-Time Issues

| Issue | Quick Fix |
|-------|-----------|
| "Invalid client credentials" | Double-check you copied the secret **value**, not the ID |
| "Insufficient privileges" | Verify admin consent was granted for API permissions |
| "Variables not found" | Ensure variables are in the **Variables** tab, not Secrets |
| "Workflows not running" | Confirm OnFusionCoE GitHub App is installed and has repo access |
| "Cannot create environment" | Ensure you completed Step 2.5 (Power Platform Management App registration) |

## Next Steps

- ✅ **You're done!** The service is ready to use
- 📖 Read [SETUP.md](./SETUP.md) for detailed documentation
- 📋 Review [WORKFLOWS.md](./WORKFLOWS.md) to understand available operations
- 🔧 Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) if issues arise

## Set a Reminder

⏰ **Important:** Your client secret will expire. Set a calendar reminder to rotate it before:

**Expiration Date:** [Date you selected in Step 3]

## Helper Script (Coming Soon)

A PowerShell script in `scripts/Set-OnFusionCoEConfig.ps1` automates this entire process including the Power Platform Management App registration!

```powershell
.\scripts\Set-OnFusionCoEConfig.ps1 -TenantId "your-tenant-id" -GitHubOrg "your-org"
```

The script handles all steps above automatically, including the critical Power Platform registration.

See [scripts/README.md](../scripts/README.md) for details.

---

**Need Help?** See full documentation in [README.md](../README.md) or contact your OnFusionCoE administrator.

**Last Updated:** November 12, 2025
