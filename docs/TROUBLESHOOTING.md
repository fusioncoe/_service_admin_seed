# OnFusionCoE Troubleshooting Guide

# OnFusionCoE Troubleshooting Guide

<p align="center">
  <img src="../media/icononly_transparent_nobuffer.png" alt="OnFusionCoE" width="60">
</p>

This guide helps you diagnose and resolve common issues with your OnFusionCoE Service Admin repository.

## Table of Contents

- [Authentication Issues](#authentication-issues)
- [Automated Secret Management](#automated-secret-management)
- [Permission Errors](#permission-errors)
- [Workflow Execution Problems](#workflow-execution-problems)
- [Configuration Issues](#configuration-issues)
- [Environment-Specific Issues](#environment-specific-issues)
- [Getting Help](#getting-help)

## Authentication Issues

### Error: "Invalid client credentials"

**Symptoms:**

- Workflow fails immediately with authentication error
- Logs show "AADSTS7000215" or similar error codes

**Causes:**

- Incorrect `FUSIONCOE_SP_APPLICATION_ID`
- Incorrect `FUSIONCOE_SP_SECRET`
- Client secret has expired

**Solutions:**

1. Verify the Application ID in GitHub variables matches Azure:
   - Go to Azure Portal → App registrations → Your app
   - Copy the **Application (client) ID**
   - Update `FUSIONCOE_SP_APPLICATION_ID` in GitHub repository variables

2. Check if the client secret has expired:
   - Go to Azure Portal → App registrations → Your app → Certificates & secrets
   - Check the expiration date
   - If expired, create a new secret and update `FUSIONCOE_SP_SECRET`

3. Ensure you copied the secret **value**, not the secret ID:
   - The secret value is shown only once when created
   - If you didn't save it, create a new secret

### Error: "Unauthorized tenant"

**Symptoms:**

- Authentication succeeds but operations fail
- Error mentions tenant mismatch

**Causes:**

- Incorrect `FUSIONCOE_SP_TENANT_ID`
- Service principal in wrong tenant

**Solutions:**

1. Verify the Tenant ID:
   - Go to Azure Portal → Azure Active Directory → Overview
   - Copy the **Tenant ID**
   - Update `FUSIONCOE_SP_TENANT_ID` in GitHub repository variables

2. Ensure the app registration is in the correct tenant

### Error: "Invalid authority"

**Symptoms:**

- Authentication fails with authority-related error

**Causes:**

- Incorrect `FUSIONCOE_SP_AUTHORITY` for your cloud environment

**Solutions:**

Use the correct authority URL for your cloud:

- **Public/Commercial:** `https://login.microsoftonline.com/`
- **GCC:** `https://login.microsoftonline.us/`
- **GCC High/DoD:** Consult your cloud administrator

## Automated Secret Management

**Important**: This section applies only to secrets that OnFusionCoE creates and manages for app registrations. Customer-managed OnFusionCoE Service Principal secrets (`FUSIONCOE_SP_APPLICATION_ID`, `FUSIONCOE_SP_SECRET`, `FUSIONCOE_SP_TENANT_ID`) remain under complete customer control and require manual management.

### Secret rotation failures

**Symptoms:**

- Notifications about secret rotation attempts for OnFusionCoE-managed app registration secrets
- Workflows failing due to authentication after OnFusionCoE secret updates
- Azure portal shows unexpected new secrets for OnFusionCoE-managed app registrations

**Causes:**

- OnFusionCoE automatic secret rotation process for service-managed app registration secrets
- OnFusionCoE-managed secrets nearing 30-day expiration window
- Self-healing response to manually deleted OnFusionCoE-managed secrets

**Solutions:**

1. **Normal Operation**: OnFusionCoE automatically manages app registration secret rotation - no action required
2. **Manual Secret Deletion**: If you manually deleted an OnFusionCoE-managed secret, OnFusionCoE will recreate it automatically
3. **GitHub Secret Updates**: OnFusionCoE automatically updates GitHub repository secrets for managed app registrations - no manual action required

**Note**: If experiencing issues with customer-managed `FUSIONCOE_SP_SECRET`, you must manually update this secret as it is not automatically managed by OnFusionCoE.

### Unexpected secret creation

**Symptoms:**

- New secrets appear in Azure portal without manual creation for OnFusionCoE-managed app registrations
- Multiple secrets exist for the same OnFusionCoE-managed app registration

**Explanation:**

This is normal behavior for OnFusionCoE-managed app registration secrets. OnFusionCoE automatically:

- Creates new secrets before current ones expire (30-day window)
- Recreates secrets if they are manually deleted (self-healing)
- Maintains resource-specific secrets for different authentication contexts

**Action Required:** None - this is automated lifecycle management for OnFusionCoE-managed secrets only

**Note**: Customer-managed `FUSIONCOE_SP_*` secrets will NOT be automatically created or managed by OnFusionCoE.

### Self-healing secret recreation

**Symptoms:**

- Secrets reappear after being deleted
- Authentication resumes after brief failure

**Explanation:**

OnFusionCoE monitors secret availability and automatically recreates secrets that are:

- Manually deleted from Azure/Entra ID
- Corrupted or inaccessible
- Missing from expected locations

**Benefits:**

- Eliminates manual secret management
- Provides resilience against accidental deletion
- Ensures continuous service availability

## Permission Errors

### Error: "Insufficient privileges"

**Symptoms:**

- Authentication succeeds but operations fail
- Error indicates missing permissions

**Causes:**

- Service principal lacks required API permissions
- Admin consent not granted

**Solutions:**

1. Review required permissions (see [SETUP.md](./SETUP.md#required-api-permissions))

2. Grant admin consent:
   - Go to Azure Portal → App registrations → Your app → API permissions
   - Click **Grant admin consent for [Your Tenant]**
   - Confirm the prompt

3. Wait a few minutes for permissions to propagate

### Error: "Access denied" for Power Platform operations

**Symptoms:**

- Can authenticate but cannot create/modify environments
- Power Platform-specific operations fail
- Environment creation workflows fail

**Causes:**

- Service principal not registered as Power Platform Management App
- Missing Power Platform API permissions
- User doesn't have Power Platform admin role (for registration)

**Solutions:**

1. **Verify Power Platform Management App registration:**

   ```powershell
   Add-PowerAppsAccount -Endpoint prod -TenantID "your-tenant-id"
   Get-PowerAppManagementApps
   ```
   
   If your Application ID is not in the list, register it:
   
   ```powershell
   New-PowerAppManagementApp -ApplicationId "your-application-id"
   ```
   
   **Important:** You must use USER credentials (not service principal) for this command.

2. Verify Power Platform API permissions in Azure

3. Ensure the user registering the app has Power Platform admin role

**Critical:** Without Power Platform Management App registration, the service **cannot** provision environments, connections, or other Power Platform resources. API permissions alone are not sufficient.

**Reference:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

### Error: "Forbidden" when managing users or groups

**Symptoms:**

- Cannot modify security groups or user assignments

**Causes:**

- Missing Microsoft Graph permissions
- Insufficient directory role

**Solutions:**

1. Ensure the following Microsoft Graph permissions are granted:
   - `Group.ReadWrite.All`
   - `User.Read.All`
   - `Application.ReadWrite.All`

2. Grant admin consent for these permissions

## Workflow Execution Problems

### Workflows not triggering

**Symptoms:**

- Expected workflows don't appear in Actions tab
- No runs show up after operations

**Causes:**

- OnFusionCoE GitHub App not installed
- Repository access not granted to the app
- Workflow files missing or corrupted

**Solutions:**

1. Verify OnFusionCoE GitHub App installation:
   - Go to GitHub Organization Settings → GitHub Apps
   - Confirm OnFusionCoE is installed
   - Check repository access permissions

2. Ensure this repository is not archived or disabled

3. Verify workflow files exist in `.github/workflows/`

### Workflow fails immediately

**Symptoms:**

- Workflow starts but fails in the first step
- No detailed error information

**Causes:**

- Missing or incorrect repository secrets/variables
- Action version incompatibility

**Solutions:**

1. Verify all required variables are set:
   - `FUSIONCOE_SP_APPLICATION_ID`
   - `FUSIONCOE_SP_TENANT_ID`
   - `FUSIONCOE_SP_AUTHORITY`
   - `FUSIONCOE_SP_CLOUD`

2. Verify all required secrets are set:
   - `FUSIONCOE_SP_SECRET`
   - `FUSIONCOE_SP_PRIVATE_KEY`

3. Check for typos in variable/secret names

### Workflow timeout

**Symptoms:**

- Workflow runs for a long time then fails with timeout

**Causes:**

- Large or complex operation
- Service connectivity issues
- Resource quota limitations

**Solutions:**

1. Check Azure/Power Platform service health

2. Verify network connectivity between GitHub and Azure

3. Review operation scope (e.g., large number of users/groups)

4. Contact OnFusionCoE support if timeouts persist

## Configuration Issues

### Error: "Invalid cloud configuration"

**Symptoms:**

- Operations fail with cloud-related errors

**Causes:**

- Incorrect `FUSIONCOE_SP_CLOUD` value
- Mismatch between cloud and authority

**Solutions:**

Ensure `FUSIONCOE_SP_CLOUD` and `FUSIONCOE_SP_AUTHORITY` match:

| Cloud | CLOUD Value | AUTHORITY Value |
|-------|-------------|-----------------|
| Commercial | `Public` | `https://login.microsoftonline.com/` |
| GCC | `GCC` | `https://login.microsoftonline.us/` |
| GCC High | `GCC High` | Consult administrator |
| DoD | `DoD` | Consult administrator |

### Variables showing as "Not set" or empty

**Symptoms:**

- Variables appear empty in Settings
- Workflows fail with missing configuration

**Causes:**

- Variables were created but never populated
- Incorrect variable scope

**Solutions:**

1. Navigate to Settings → Secrets and variables → Actions → Variables

2. Click on each variable and enter the value

3. Ensure variables are set at the repository level, not environment level

### Private key issues

**Symptoms:**

- Error about output encryption
- Cannot decrypt workflow outputs

**Causes:**

- `FUSIONCOE_SP_PRIVATE_KEY` missing or incorrect

**Solutions:**

1. The private key is provided by the OnFusionCoE service

2. Contact your OnFusionCoE administrator if it's missing

3. Do not attempt to generate this key manually

## Environment-Specific Issues

### Cannot create environments in desired region

**Symptoms:**

- Environment creation fails with region error
- Desired region not available

**Causes:**

- Region restrictions in your tenant
- Capacity limitations
- Compliance requirements

**Solutions:**

1. Check Power Platform Admin Center for available regions

2. Review tenant region restrictions

3. Contact Power Platform admin to enable desired regions

### Environment creation succeeds but environment not usable

**Symptoms:**

- Environment appears in Power Platform but is in provisioning state
- Cannot access environment

**Causes:**

- Provisioning still in progress
- Dataverse database provisioning pending
- Service principal not registered as Power Platform Management App

**Solutions:**

1. Wait 10-15 minutes for provisioning to complete

2. Check environment status in Power Platform Admin Center

3. Review environment creation logs for errors

4. **Verify Power Platform Management App registration:**

   ```powershell
   Get-PowerAppManagementApps
   ```
   
   If your app is not listed, workflows will fail to provision environments properly.

**Reference:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

### Maker permissions not applying

**Symptoms:**

- User granted maker permissions but cannot create apps

**Causes:**

- Permissions not yet propagated
- User needs to sign out and back in
- License assignment issues

**Solutions:**

1. Wait 5-10 minutes for permissions to propagate

2. Have user sign out of Power Platform and sign back in

3. Verify user has appropriate licenses assigned

4. Check security role assignments in Power Platform Admin Center

## Debugging Tips

### Enable verbose logging

Workflow logs are automatically captured. To get more details:

1. Go to Actions tab
2. Click on the failed run
3. Expand all workflow steps
4. Look for detailed error messages from OnFusionCoE actions

### Check Azure sign-in logs

1. Go to Azure Portal → Azure Active Directory → Sign-in logs
2. Filter by the service principal application ID
3. Review failed sign-in attempts and error codes

### Review Power Platform audit logs

1. Go to Power Platform Admin Center
2. Navigate to audit logs
3. Filter by the timeframe of the failed operation
4. Look for related events

### Validate configuration manually

Test service principal authentication manually:

```powershell
# Install required module
Install-Module -Name Microsoft.Graph.Authentication

# Connect using service principal
$tenantId = "your-tenant-id"
$appId = "your-app-id"
$secret = "your-client-secret" | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($appId, $secret)

Connect-MgGraph -ClientSecretCredential $credential -TenantId $tenantId
```

## Common Error Codes

### Azure AD Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| AADSTS7000215 | Invalid client secret | Verify secret value and expiration |
| AADSTS70011 | Invalid scope | Check API permissions |
| AADSTS50034 | User not found | Verify tenant ID |
| AADSTS90002 | Tenant not found | Check tenant ID |
| AADSTS650052 | App requires consent | Grant admin consent |

### HTTP Status Codes

| Code | Meaning | Common Causes |
|------|---------|---------------|
| 401 | Unauthorized | Authentication failure |
| 403 | Forbidden | Missing permissions |
| 404 | Not found | Resource doesn't exist |
| 429 | Too many requests | Rate limiting |
| 500 | Server error | Service issue |

## Getting Help

### Information to Gather

When seeking help, collect:

1. **Workflow run URL** - Link to the failed run in Actions tab
2. **Error messages** - Full error text from logs
3. **Configuration** - Variable names (not values!) that are set
4. **Timing** - When the issue started occurring
5. **Recent changes** - Any recent configuration or setup changes

### Support Channels

1. **Review documentation**
   - Check [README.md](../README.md)
   - Review [SETUP.md](./SETUP.md)
   - Read [WORKFLOWS.md](./WORKFLOWS.md)

2. **Check workflow logs**
   - Actions tab → Select workflow → View run details

3. **Azure diagnostics**
   - Review Azure AD sign-in logs
   - Check app registration configuration

4. **Contact administrator**
   - Your OnFusionCoE service administrator
   - Your Azure/Power Platform administrator

### Before Contacting Support

- [ ] Verified all variables are set correctly
- [ ] Checked all secrets are populated
- [ ] Confirmed service principal permissions
- [ ] **Verified Power Platform Management App registration**
- [ ] Reviewed workflow run logs
- [ ] Checked for service health issues
- [ ] Attempted basic troubleshooting steps

**Quick check for Power Platform registration:**

```powershell
Add-PowerAppsAccount -Endpoint prod -TenantID "your-tenant-id"
Get-PowerAppManagementApps
# Verify your Application ID appears in the list
```

## Preventive Measures

### Regular maintenance

- **Rotate secrets** - Before they expire (set calendar reminders)
- **Review permissions** - Quarterly audit of service principal permissions
- **Monitor runs** - Regular review of workflow execution patterns
- **Update documentation** - Keep team docs current with any custom configurations

### Best practices

- **Use least privilege** - Only grant necessary permissions
- **Separate environments** - Different service principals for dev/prod
- **Document changes** - Keep a change log for configuration updates
- **Test changes** - Verify configuration changes in a test environment first

## Getting Additional Help

If the troubleshooting steps above don't resolve your issue:

1. **OnFusionCoE Portal**: Visit [https://devops.onfusioncoe.com](https://devops.onfusioncoe.com) for:
   - Service status and health dashboards
   - Support ticket submission
   - Known issues and announcements
   - Service documentation and updates

2. **Gather diagnostic information**:
   - GitHub Actions workflow run URL
   - Error messages from workflow logs
   - Entra ID sign-in logs (if authentication-related)
   - Repository configuration (variables/secrets names, not values)
   - Cloud environment (Public, GCC, GCC High, DoD)

3. **Contact your OnFusionCoE service administrator** with the gathered information

4. **Check recent changes**:
   - Recent workflow file modifications
   - Recent secret/variable updates
   - Recent Entra ID permission changes
   - Recent Power Platform configuration changes

---

**Last Updated:** November 12, 2025
