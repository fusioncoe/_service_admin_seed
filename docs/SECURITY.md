# OnFusionCoE Security Architecture

<p align="center">
  <img src="../media/icononly_transparent_nobuffer.png" alt="OnFusionCoE" width="60">
</p>

This document explains the security mechanisms used by OnFusionCoE to protect your data and authenticate workflow operations.

## Overview

OnFusionCoE implements a **zero-trust security model** with multiple layers of protection:

1. **Credential Isolation** - Your credentials never leave your GitHub environment
2. **Authentication** - Multi-scope OAuth2 authentication to Microsoft services
3. **Data Integrity** - Cryptographic verification of all workflow outputs
4. **Origin Verification** - Confirming outputs come from your authorized repository
5. **Encrypted Communication** - Secure data encryption, with libsodium used specifically for GitHub repository and environment secrets for new App Registrations

### Zero-Trust Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Your GitHub Account                                          │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Service Admin Repository (_service_admin_seed)          │ │
│ │ • Variables & Secrets (You Control)                    │ │
│ │ • GitHub Actions Workflows                             │ │
│ │ • OnFusionCoE Actions (Secure Proxy)                  │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Workflow Dispatch
                              │ (via OnFusionCoE GitHub App)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ OnFusionCoE Service                                         │
│ • Orchestrates workflow execution                          │
│ • NEVER sees your credentials                             │
│ • Sends encrypted operation payloads                      │
│ • Receives cryptographically signed results              │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Secure API Calls
                              │ (using YOUR credentials)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ Microsoft Cloud Resources                                   │
│ • Entra ID (Azure AD)                                      │
│ • Power Platform                                           │
│ • Microsoft Graph API                                      │
└─────────────────────────────────────────────────────────────┘
```

**Key Security Principles:**

1. **No Secret Sharing**: No secrets are ever shared with the OnFusionCoE service
2. **ID-Only Orchestration**: OnFusionCoE tracks only specific IDs (tenant/application IDs, secret IDs, connection identities) - never actual secret values
3. **Secure Proxy**: GitHub Actions authenticate on your behalf using your credentials
4. **Automated Secret Management**: Service automatically rotates secrets within 30 days of expiration and recovers from secret removal
5. **Audit Trail**: Complete operation history in your GitHub Actions runs
6. **Revocable Access**: You maintain full control over permissions and access

## FsnxApiClient - The Secure Execution Layer

All workflow actions use the `FsnxApiClient` class from the [`fusioncoe/onfusioncoe-actions-g2`](https://github.com/fusioncoe/onfusioncoe-actions-g2/tree/v0) repository. This client provides:

### Core Capabilities

- **Multi-Scope Authentication**: Handles OAuth2 with Microsoft Graph and Power Platform APIs
- **Token Caching**: Efficiently caches authentication tokens per scope to minimize auth requests
- **Event Processing**: Securely processes encrypted webhook payloads from OnFusionCoE
- **Step-Based Execution**: Conditional execution based on workflow orchestration steps
- **Secure Communication**: Encrypts/decrypts sensitive data using libsodium encryption

### Security Features

- **Client Credential Flow**: Uses Azure AD application credentials for authentication
- **Scope-Based Access**: Fine-grained permissions per operation (Microsoft Graph, Power Platform)
- **ID-Only Backend**: Service tracks specific IDs only - never accesses actual secrets:
  - Tenant and application IDs for service management app registration
  - App registration secret IDs (but not the actual secret values)
  - Environment-specific DevOps and Power Automate connection identities
- **Automated Secret Lifecycle Management**: For app registration secrets created by the service:
  - Tracks secret ID, creation date, expiration date for current and previous versions
  - Automatically updates secrets within 30 days of expiration
  - Creates new secrets if existing ones are removed from Azure/Entra ID
  - Uses dedicated secrets for each resource requiring app registration authentication
  - Names secrets to indicate their specific resource usage scope
- **Secret Isolation & Scoping**:
  - GitHub repository and environment secrets encrypted using libsodium for new App Registrations
  - Each secret dedicated to a specific resource with narrow scope of use
  - Secrets never exposed outside their intended resource context
  - Resource-specific naming convention prevents cross-resource secret usage
- **No Secret Sharing**: OnFusionCoE service never accesses or stores actual customer secrets
- **Compromise Resistance**: Narrow secret scoping makes compromised secrets very unlikely
- **Dual App Registration Management**: Backend manages two types of app registrations:
  - Service management app registration (tenant/application IDs)
  - Environment-specific DevOps and Power Automate connection identities

## Service Principal Authentication

### Purpose

The service principal (configured via `FUSIONCOE_SP_APPLICATION_ID`, `FUSIONCOE_SP_TENANT_ID`, and `FUSIONCOE_SP_SECRET`) authenticates GitHub Actions workflows to Azure and Power Platform services.

### Components

| Component | Purpose | Managed By |
|-----------|---------|------------|
| `FUSIONCOE_SP_APPLICATION_ID` | Identifies the Entra ID app registration | You (customer) |
| `FUSIONCOE_SP_TENANT_ID` | Identifies your Entra ID tenant | You (customer) |
| `FUSIONCOE_SP_SECRET` | Client secret for authentication | You (customer) |
| `FUSIONCOE_SP_AUTHORITY` | Authentication authority URL | You (customer) |

### Security Best Practices

- **Rotate secrets regularly** - Client secrets should be rotated before expiration (recommended: every 6-12 months)
- **Use minimum required permissions** - Only grant API permissions necessary for OnFusionCoE operations
- **Monitor sign-in logs** - Review Entra ID sign-in logs for unusual activity
- **Protect secrets** - Never commit secrets to source control or share them via unsecured channels

## Automated Secret Lifecycle Management

OnFusionCoE provides enterprise-grade automated secret lifecycle management that eliminates manual secret rotation tasks and provides self-healing capabilities.

### Secret Rotation Process

- **Automatic Rotation**: All app registration secrets are automatically rotated within 30 days of their expiration date
- **Proactive Updates**: New secrets created before current ones expire to ensure continuous operation
- **Zero Downtime**: Rotation process designed to maintain service availability during updates
- **Version Management**: System tracks current and previous secret versions during transition periods

### Self-Healing Capabilities

- **Missing Secret Detection**: Service automatically detects when secrets are removed from Azure/Entra ID
- **Automatic Recreation**: Creates new secrets immediately when existing ones are deleted or corrupted
- **Resource Monitoring**: Continuously monitors secret availability across all connected resources
- **Failure Recovery**: Automatic recovery from secret-related authentication failures

### Resource-Specific Secret Scoping

- **Dedicated Secrets**: Each resource requiring authentication receives its own unique secret
- **Named Scoping**: Secret names indicate their specific resource usage to prevent cross-resource usage
- **Narrow Scope Usage**: Each secret is limited to its intended resource context only
- **Isolation Boundaries**: Secrets cannot be used outside their designated resource scope

### Compromise Resistance Features

- **Limited Blast Radius**: Compromised secrets affect only their specific resource due to narrow scoping
- **Rapid Rotation**: 30-day maximum lifetime limits exposure window for compromised secrets
- **Detection and Response**: Automated detection of unusual secret usage patterns
- **Immediate Invalidation**: Compromised secrets can be immediately rotated without affecting other resources

### Security Architecture

- **ID-Only Backend Tracking**: OnFusionCoE backend tracks specific IDs only - never actual secrets:
  - Tenant and application IDs for service management app registration
  - App registration secret IDs (but not the actual secret values)
  - Environment-specific DevOps and Power Automate connection identities
- **libsodium Encryption**: GitHub repository and environment secrets encrypted using libsodium for newly created App Registrations
- **No Secret Exposure**: Secrets never transmitted or stored outside their intended GitHub repository/environment
- **Zero Trust Model**: No component trusts that secrets will remain valid - all components verify authentication in real-time

### Dual App Registration Management

OnFusionCoE manages two distinct types of app registrations:

1. **Service Management App Registrations**: Used for backend service operations (tenant/application IDs only)
2. **Environment-Specific Identities**: DevOps and Power Automate connection identities for each environment

This separation ensures that service management operations are isolated from environment-specific authentication.

## Workflow Output Authentication

### Architecture Overview

When GitHub Actions workflows complete operations, they send results back to the OnFusionCoE service via HTTPS API calls. To ensure these outputs are authentic and haven't been tampered with, OnFusionCoE implements a cryptographic signing mechanism.

### Private/Public Key Pair

**Key Generation:**
- OnFusionCoE automatically creates a unique private/public key pair for each `_service_admin_seed` repository
- The **private key** is stored in the `FUSIONCOE_SP_PRIVATE_KEY` repository secret
- The **public key** is retained by the OnFusionCoE service
- Key pairs are automatically rotated daily for enhanced security

**Key Management:**
- **Customer responsibility:** None - keys are fully managed by OnFusionCoE
- **Rotation frequency:** Daily (automatic)
- **Storage:** Private key in GitHub Secrets, public key in OnFusionCoE service database

### Output Signing Process

When a workflow sends results back to OnFusionCoE, the following process occurs:

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Workflow generates output payload (JSON data)                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. Compute SHA-256 hash of the payload                          │
│    Hash = SHA256(payload)                                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. Encrypt the hash using FUSIONCOE_SP_PRIVATE_KEY (RSA)       │
│    EncryptedHash = RSA_Encrypt(Hash, PrivateKey)                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. Send to OnFusionCoE API with headers:                        │
│    • fusionex-output-sha: Hash                                  │
│    • fusionex-auth-rsa-sha: EncryptedHash                       │
│    • Body: payload                                              │
└─────────────────────────────────────────────────────────────────┘
```

### Output Verification Process

When OnFusionCoE receives a workflow output, it performs these validation steps:

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Receive API call with payload and headers                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. Verify payload integrity                                     │
│    ComputedHash = SHA256(payload)                               │
│    IF ComputedHash ≠ fusionex-output-sha THEN REJECT           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. Verify signature authenticity                                │
│    DecryptedHash = RSA_Decrypt(fusionex-auth-rsa-sha, PublicKey)│
│    IF DecryptedHash ≠ fusionex-output-sha THEN REJECT          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. Process authenticated output                                 │
│    ✓ Payload is unmodified (integrity verified)                │
│    ✓ Output came from customer's repository (origin verified)  │
└─────────────────────────────────────────────────────────────────┘
```

### Security Guarantees

This dual-verification approach provides:

1. **Data Integrity** - The payload hash ensures data wasn't modified in transit
2. **Authenticity** - The encrypted signature proves the output came from your repository
3. **Non-repudiation** - Only your repository's private key could have created the signature
4. **Replay Protection** - Daily key rotation limits the window for potential replay attacks

### What This Means for You

**As a user, you don't need to:**
- Generate or manage the key pair
- Configure the signing mechanism
- Rotate the keys manually
- Understand cryptographic implementation details

**OnFusionCoE automatically:**
- Creates the key pair when your repository is provisioned
- Stores the private key securely in GitHub Secrets
- Rotates keys daily
- Handles all signing and verification operations

**You should:**
- Ensure the `FUSIONCOE_SP_PRIVATE_KEY` secret is not deleted or modified manually
- Contact your OnFusionCoE administrator if the secret is missing or workflows fail with authentication errors

## Repository Secrets Protection

### GitHub Secrets Security

All sensitive values are stored as GitHub repository secrets, which:

- Are encrypted at rest
- Are not visible in workflow logs
- Cannot be exported or viewed after creation
- Are only accessible during workflow execution
- Are masked in workflow outputs

### Secret Access Control

- **Repository secrets** are only accessible to workflows in the same repository
- **Environment secrets** (if used) require manual approval before deployment
- **Organization secrets** (if used) can be restricted to specific repositories

### Best Practices

1. **Never log secrets** - Avoid `echo $SECRET` or similar commands in workflows
2. **Use secret scanning** - Enable GitHub secret scanning to detect leaked credentials
3. **Limit repository access** - Only grant write access to trusted administrators
4. **Review workflow changes** - Require pull request reviews for workflow modifications
5. **Monitor audit logs** - Regularly review GitHub audit logs for unauthorized access

## Encryption in Transit

### HTTPS/TLS

All communications use HTTPS with TLS 1.2 or higher:

- **GitHub Actions → Azure/Power Platform** - Authenticated via service principal
- **GitHub Actions → OnFusionCoE API** - Authenticated via signed payloads
- **You → Azure Portal** - Browser-based HTTPS
- **You → GitHub** - Browser-based HTTPS

### Certificate Validation

- All HTTPS connections validate server certificates
- Certificate pinning is not used (relies on system trust store)
- Invalid certificates cause connection failures (fail-secure)

## API Permissions and Least Privilege

### Principle of Least Privilege

The service principal should only have permissions necessary for OnFusionCoE operations:

**Required Permissions:**
- **Microsoft Graph API:**
  - `Application.ReadWrite.All` - Manage app registrations
  - `Group.ReadWrite.All` - Manage security groups
  - `User.Read.All` - Read user information
  
- **Power Platform API:**
  - `Tenant.ReadWrite.All` - Manage Power Platform resources

**Not Required:**
- Global Administrator role
- Subscription Owner/Contributor roles
- Exchange, SharePoint, or Teams admin roles
- Permissions beyond those listed above

### Permission Scope

- Permissions are **application-level** (not delegated)
- Service principal operates **without user context**
- Admin consent is required for all permissions
- Permissions apply **tenant-wide** (cannot be scoped to specific resources)

### Permission Review

Regularly review app registration permissions:

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All"

# View app permissions
$app = Get-MgApplication -Filter "appId eq 'your-app-id'"
$app.RequiredResourceAccess | ForEach-Object {
    $resourceApp = Get-MgServicePrincipal -Filter "appId eq '$($_.ResourceAppId)'"
    Write-Host "Resource: $($resourceApp.DisplayName)"
    $_.ResourceAccess | ForEach-Object {
        $permission = $resourceApp.AppRoles | Where-Object { $_.Id -eq $_.Id }
        Write-Host "  - $($permission.Value)"
    }
}
```

## Compliance and Auditing

### Audit Logs

OnFusionCoE activities can be audited through:

1. **Entra ID Sign-in Logs** - Service principal authentication events
2. **Entra ID Audit Logs** - App registration and permission changes
3. **GitHub Audit Logs** - Workflow executions and secret access
4. **Power Platform Audit Logs** - Environment and resource modifications
5. **OnFusionCoE Service Logs** - Operation history and outcomes (contact your administrator)

### Compliance Frameworks

OnFusionCoE supports deployments in:

- **Commercial Cloud (Public)** - Standard Azure/Microsoft 365
- **GCC (Government Community Cloud)** - US Government customers
- **GCC High** - US Government agencies with stringent compliance requirements
- **DoD** - US Department of Defense environments

Each cloud has specific compliance certifications. Consult your OnFusionCoE administrator for details.

## Incident Response

### If `FUSIONCOE_SP_SECRET` is Compromised

1. **Immediately rotate** the client secret in Azure Portal
2. **Update** the `FUSIONCOE_SP_SECRET` repository secret
3. **Review** Entra ID sign-in logs for unauthorized access
4. **Investigate** any unexpected Power Platform or Entra ID changes
5. **Report** the incident to your security team

### If `FUSIONCOE_SP_PRIVATE_KEY` is Compromised

1. **Contact** your OnFusionCoE administrator immediately
2. **Do not** attempt to regenerate the key yourself
3. The OnFusionCoE service will:
   - Generate a new key pair
   - Update the repository secret
   - Invalidate the old public key
4. **Monitor** workflow executions for failures during key rotation

### If Service Principal is Compromised

1. **Disable** the service principal in Entra ID immediately
2. **Revoke** all active sessions
3. **Create** a new app registration with new credentials
4. **Update** repository variables and secrets
5. **Review** audit logs for unauthorized activities
6. **Re-register** as Power Platform Management App with new credentials

## Security Checklist

Use this checklist to ensure your OnFusionCoE setup follows security best practices:

- [ ] Service principal has only required API permissions (no extra permissions)
- [ ] Admin consent has been granted for all API permissions
- [ ] Client secret expiration is tracked (calendar reminder set)
- [ ] `FUSIONCOE_SP_SECRET` is stored only in GitHub Secrets (not documented elsewhere)
- [ ] Repository has branch protection enabled for workflow files
- [ ] Only authorized users have repository admin access
- [ ] GitHub secret scanning is enabled
- [ ] Entra ID sign-in logs are monitored regularly
- [ ] Service principal is registered as Power Platform Management App
- [ ] Multi-factor authentication (MFA) is enabled for all users with repository access
- [ ] Workflow logs are reviewed periodically for errors or anomalies
- [ ] `FUSIONCOE_SP_PRIVATE_KEY` secret exists and is managed by OnFusionCoE

## Additional Resources

- [Microsoft Entra ID Security Best Practices](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/security-operations-introduction)
- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Power Platform Security](https://learn.microsoft.com/en-us/power-platform/admin/security/overview)
- [Azure AD App Registration Best Practices](https://learn.microsoft.com/en-us/azure/active-directory/develop/security-best-practices-for-app-registration)

## Support

For security questions or incident response:

1. **OnFusionCoE Portal**: [https://devops.onfusioncoe.com](https://devops.onfusioncoe.com) - Service status and support
2. Review this documentation
3. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
4. Contact your OnFusionCoE administrator
5. For critical security incidents, follow your organization's incident response procedures

---

**Last Updated:** November 12, 2025  
**Document Version:** 1.0
