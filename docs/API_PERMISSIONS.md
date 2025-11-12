# API Permissions Reference

This document details the API permissions required for OnFusionCoE Service Admin operations.

## Overview

The OnFusionCoE service principal requires specific permissions from two resource providers:

1. **Power Platform API** (Dynamics CRM) - For managing Power Platform environments
2. **Microsoft Graph** - For managing Entra ID resources

## Required Permissions

### Power Platform API

**Resource App ID:** `c9299480-c13a-49db-a7ae-cdfe54fe0313`

| Permission Name | ID | Type | Purpose |
|----------------|-----|------|---------|
| Tenant.ReadWrite.All | `640bd519-35de-4a25-994f-ae29551cc6d2` | Application | Full access to manage Power Platform tenant and environments |

**Why This Permission:**

- Create and configure Power Platform environments
- Manage environment settings and capacity
- Configure Dataverse databases
- Assign security roles and permissions

### Microsoft Graph

**Resource App ID:** `00000003-0000-0000-c000-000000000000`

| Permission Name | ID | Type | Purpose |
|----------------|-----|------|---------|
| User.Read | `e1fe6dd8-ba31-4d61-89e7-88639da4683d` | Delegated | Sign in and read user profile |
| Application.ReadWrite.All | `1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9` | Application | Manage app registrations |
| Application.ReadWrite.OwnedBy | `18a4783c-866b-4cc7-a460-3d5e5662c884` | Application | Manage apps owned by this app |
| Directory.ReadWrite.All | `8e8e4742-1d95-4f68-9d56-6ee75648c72a` | Application | Read and write directory data |
| Group.ReadWrite.All | `62a82d76-70ea-41e2-9197-370581804d09` | Application | Manage all groups |
| User.ReadWrite.All | `498476ce-e0fe-48b0-b801-37ba7e2685c6` | Application | Manage all users |
| Directory.Read.All | `7ab1d382-f21e-4acd-a863-ba3e13f7da61` | Application | Read directory data |

**Why These Permissions:**

- **User.Read (Delegated):** Required for interactive sign-in scenarios
- **Application.ReadWrite.All:** Create and manage app registrations for solutions
- **Application.ReadWrite.OwnedBy:** Manage app registrations created by this service
- **Directory.ReadWrite.All:** Full directory access for complex operations
- **Group.ReadWrite.All:** Create and manage security groups for environment access
- **User.ReadWrite.All:** Assign users to groups and roles
- **Directory.Read.All:** Read directory information for validation

## Permission Types

### Application Permissions (Role)

- Used when the app runs as itself (service principal)
- Requires admin consent
- No user context needed
- Used for most OnFusionCoE operations

### Delegated Permissions (Scope)

- Used when the app acts on behalf of a signed-in user
- Requires user consent (or admin consent for sensitive permissions)
- User context required
- Used for interactive operations

## Manifest Format

If you need to configure permissions via the app registration manifest, use this format:

```json
{
  "requiredResourceAccess": [
    {
      "resourceAppId": "c9299480-c13a-49db-a7ae-cdfe54fe0313",
      "resourceAccess": [
        {
          "id": "640bd519-35de-4a25-994f-ae29551cc6d2",
          "type": "Role"
        }
      ]
    },
    {
      "resourceAppId": "00000003-0000-0000-c000-000000000000",
      "resourceAccess": [
        {
          "id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
          "type": "Scope"
        },
        {
          "id": "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9",
          "type": "Role"
        },
        {
          "id": "18a4783c-866b-4cc7-a460-3d5e5662c884",
          "type": "Role"
        },
        {
          "id": "8e8e4742-1d95-4f68-9d56-6ee75648c72a",
          "type": "Role"
        },
        {
          "id": "62a82d76-70ea-41e2-9197-370581804d09",
          "type": "Role"
        },
        {
          "id": "498476ce-e0fe-48b0-b801-37ba7e2685c6",
          "type": "Role"
        },
        {
          "id": "7ab1d382-f21e-4acd-a863-ba3e13f7da61",
          "type": "Role"
        }
      ]
    }
  ]
}
```

## Cloud-Specific Considerations

### Commercial Cloud (Public)

All permissions listed above apply as-is.

### Government Clouds (GCC, GCC High, DoD)

The same permission IDs apply across all Azure clouds. However:

- **Resource App IDs are consistent** across clouds
- **Permission IDs (GUIDs) are consistent** across clouds
- **API endpoints differ** but permissions remain the same
- **Admin consent process** follows the same pattern

## Granting Admin Consent

### Via Azure Portal

1. Navigate to **Azure Portal** → **Azure Active Directory** → **App registrations**
2. Select your app registration
3. Click **API permissions** in the left menu
4. Click **Grant admin consent for [Your Tenant]**
5. Confirm the consent dialog

### Via PowerShell

```powershell
# Connect to Azure AD
Connect-AzureAD

# Get the service principal for your app
$sp = Get-AzureADServicePrincipal -Filter "AppId eq 'your-app-id'"

# Grant consent (requires appropriate admin permissions)
# This is complex - recommend using Azure Portal
```

### Via Microsoft Graph API

```http
POST https://graph.microsoft.com/v1.0/oauth2PermissionGrants
Content-Type: application/json

{
  "clientId": "{service-principal-object-id}",
  "consentType": "AllPrincipals",
  "principalId": null,
  "resourceId": "{resource-service-principal-object-id}",
  "scope": "User.Read"
}
```

## Power Platform Management App Registration

**Important:** Beyond the API permissions above, the app must also be registered as a Power Platform Management App using:

```powershell
New-PowerAppManagementApp -ApplicationId {your-app-id}
```

**This step is CRITICAL:** Without this registration, the service principal **cannot** provision Power Platform resources including:

- Power Platform environments
- Dataverse databases
- Power Automate connections
- Environment security configurations
- Maker permissions

**Key Requirements:**

- Must use **USER credentials** (not service principal)
- User must have **Power Platform admin** permissions
- Cannot be done via Azure Portal or Graph API
- Requires PowerShell modules:
  - Microsoft.PowerApps.Administration.PowerShell
  - Microsoft.PowerApps.PowerShell

**Cloud Endpoints:**

- **Commercial:** `prod`
- **GCC:** `usgov`
- **GCC High:** `usgovhigh`
- **DoD:** `dod`

**Official Documentation:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

## Verification

### Check API Permissions in Portal

1. Azure Portal → App registrations → Your app
2. Click **API permissions**
3. Verify all permissions show "Granted for [Tenant]"

### Check via PowerShell

```powershell
# Get the app registration
$app = Get-AzADApplication -ApplicationId "your-app-id"

# View required resource access
$app.RequiredResourceAccess | ForEach-Object {
    Write-Host "Resource: $($_.ResourceAppId)"
    $_.ResourceAccess | ForEach-Object {
        Write-Host "  Permission: $($_.Id) (Type: $($_.Type))"
    }
}
```

### Check Power Platform Registration

```powershell
# Connect to Power Platform
Add-PowerAppsAccount -Endpoint prod -TenantID "your-tenant-id"

# Get management apps
Get-PowerAppManagementApps

# Should show your ApplicationId in the results
```

**If your app is not listed:** The service will fail to provision Power Platform resources (environments, connections, etc.). You must complete the Power Platform Management App registration.

**Reference:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

## Troubleshooting

### Permission Not Available

If a permission doesn't appear in the Azure Portal:

- Ensure you're in the correct cloud environment
- Verify the resource app exists in your tenant
- Check if Power Platform is enabled in your tenant

### Admin Consent Fails

If admin consent fails:

- Verify you have Global Administrator or Privileged Role Administrator role
- Check if your tenant has restrictions on admin consent
- Review Azure AD sign-in logs for specific errors

### Power Platform Registration Fails

If `New-PowerAppManagementApp` fails:

- Ensure you're using USER credentials (not service principal)
- Verify user has Power Platform admin role
- Check you're connected to the correct cloud endpoint
- Confirm API permissions have been granted

**Without this registration, OnFusionCoE cannot provision Power Platform environments or connections.**

**Reference:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

## Security Best Practices

### Principle of Least Privilege

The permissions listed are required for full OnFusionCoE functionality. If you only use specific features:

- Review which workflows you actually use
- Consider removing unused permissions
- Document any custom permission sets

### Regular Auditing

- Review API permissions quarterly
- Check for unused or excessive permissions
- Audit who has admin consent capabilities
- Monitor sign-in logs for suspicious activity

### Rotation and Monitoring

- Rotate client secrets regularly (before expiration)
- Enable sign-in logging and monitoring
- Set up alerts for failed authentications
- Review audit logs for permission changes

## Additional Resources

- [Microsoft Graph Permissions Reference](https://learn.microsoft.com/en-us/graph/permissions-reference)
- [Power Platform PowerShell - Create Service Principal](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)
- [Azure AD App Registration Documentation](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
- [Power Platform Admin PowerShell](https://learn.microsoft.com/en-us/power-platform/admin/powershell-getting-started)

---

**Last Updated:** November 12, 2025
