# OnFusionCoE Architecture Overview

<p align="center">
  <img src="../media/icononly_transparent_nobuffer.png" alt="OnFusionCoE" width="60">
</p>

This document explains how OnFusionCoE components work together to provide secure, automated Power Platform DevOps.

## System Architecture

OnFusionCoE is a DevOps-as-a-Service platform that orchestrates Power Platform and Entra ID resource management through a zero-trust security architecture.

### High-Level Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Developer Activity                                            │
│    • Creates feature branch                                      │
│    • Commits Power Platform solution                            │
│    • Opens pull request                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. OnFusionCoE Service (Backend)                                │
│    • Detects development activity                               │
│    • Determines required resources                              │
│    • Prepares encrypted operation payload                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. GitHub App Integration                                       │
│    • Service triggers repository_dispatch event                 │
│    • Targets specific workflow in _service_admin_seed repo     │
│    • Passes encrypted payload                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. GitHub Actions Workflow Execution                            │
│    • Workflow triggered in customer's repository                │
│    • Uses onfusioncoe-actions-g2 action                        │
│    • Accesses customer's secrets (never exposed to service)    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. FsnxApiClient Processing                                     │
│    • Authenticates using customer's service principal           │
│    • Decrypts operation payload from OnFusionCoE               │
│    • Executes Microsoft API calls (Graph, Power Platform)      │
│    • Creates cryptographically signed result                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. Result Submission                                            │
│    • Computes SHA-256 hash of result payload                   │
│    • Encrypts hash with private key (RSA)                      │
│    • Sends to OnFusionCoE API with headers:                    │
│      - fusionex-output-sha                                     │
│      - fusionex-auth-rsa-sha                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. OnFusionCoE Service Verification                            │
│    • Verifies payload integrity (hash comparison)              │
│    • Verifies authenticity (decrypts signature with public key)│
│    • Processes validated result                                │
│    • Updates orchestration state                               │
└─────────────────────────────────────────────────────────────────┘
```

## Repository Structure

### Service Admin Repository (_service_admin_seed)

**Purpose**: Customer-controlled repository containing workflows and credentials

**Key Components**:
- **GitHub Workflows** (`.github/workflows/`): Workflow definitions for each operation type
- **Repository Secrets**: Customer's service principal credentials and private key
- **Repository Variables**: Cloud configuration and tenant information
- **Documentation** (`docs/`): Setup guides, troubleshooting, security documentation
- **Helper Scripts** (`scripts/`): Automation for setup and configuration

**Ownership**: Customer (you)

**Access Control**: Customer maintains full control; OnFusionCoE service never has access

### OnFusionCoE Actions Repository (onfusioncoe-actions-g2)

**Purpose**: Reusable GitHub Actions that serve as secure execution proxies

**Location**: [`https://github.com/fusioncoe/onfusioncoe-actions-g2/tree/v0`](https://github.com/fusioncoe/onfusioncoe-actions-g2/tree/v0)

**Key Components**:
- **FsnxApiClient**: Core authentication and API interaction client
- **Individual Actions**: Specialized actions for each operation type
  - `create-power-platform-environment`
  - `ensure-entraid-app-registration`
  - `ensure-security-group`
  - `ensure-maker`
  - And more...

**Ownership**: FusionCoE

**Access**: Public repository, referenced by customer workflows via `uses:` statements

## Security Boundaries

### What Stays in Your Environment

✅ **Service Principal Credentials**
- Application (client) ID
- Client secret
- Tenant ID

✅ **Private Key**
- Used for signing workflow outputs
- Rotated daily by OnFusionCoE
- Stored in GitHub Secrets

✅ **GitHub Actions Execution**
- Runs in your GitHub account
- Uses your GitHub Actions minutes
- Complete logs in your Actions history

### What OnFusionCoE Never Sees

❌ **Your Credentials**: Service principal secrets remain in GitHub Secrets
❌ **Authentication Tokens**: OAuth tokens generated and used only in your workflows
❌ **Raw API Responses**: Microsoft API responses processed in your environment
❌ **Unencrypted Data**: All payloads encrypted before leaving your environment

### What OnFusionCoE Manages

✅ **Orchestration Logic**: Determines when and what workflows to trigger
✅ **Encrypted Payloads**: Sends encrypted operation instructions
✅ **Result Verification**: Validates authenticity and integrity of workflow outputs
✅ **State Management**: Tracks overall DevOps process state
✅ **Key Pair Management**: Generates and rotates private/public key pairs daily

## Authentication Flows

### Service Principal → Microsoft Cloud

```
┌──────────────────────┐
│ GitHub Actions       │
│ Workflow Execution   │
└──────────────────────┘
          │
          │ Reads from GitHub Secrets
          ▼
┌──────────────────────┐
│ FsnxApiClient        │
│ OAuth2 Client        │
└──────────────────────┘
          │
          │ Client Credentials Flow
          │ (client_id + client_secret)
          ▼
┌──────────────────────┐
│ Microsoft Identity   │
│ Platform             │
└──────────────────────┘
          │
          │ Returns access token
          ▼
┌──────────────────────┐
│ FsnxApiClient        │
│ Token Cache          │
└──────────────────────┘
          │
          │ Uses token for API calls
          ▼
┌──────────────────────┐
│ Microsoft Graph API  │
│ Power Platform API   │
└──────────────────────┘
```

### Workflow Output → OnFusionCoE Service

```
┌──────────────────────┐
│ FsnxApiClient        │
│ Operation Complete   │
└──────────────────────┘
          │
          │ Generate result payload
          ▼
┌──────────────────────┐
│ SHA-256 Hash         │
│ Hash(payload)        │
└──────────────────────┘
          │
          │ Read private key from GitHub Secret
          ▼
┌──────────────────────┐
│ RSA Encryption       │
│ Encrypt(hash, key)   │
└──────────────────────┘
          │
          │ HTTPS POST with headers:
          │ • fusionex-output-sha
          │ • fusionex-auth-rsa-sha
          ▼
┌──────────────────────┐
│ OnFusionCoE API      │
│ Result Endpoint      │
└──────────────────────┘
          │
          │ Verify integrity and authenticity
          ▼
┌──────────────────────┐
│ OnFusionCoE Service  │
│ Process Result       │
└──────────────────────┘
```

## Workflow Types

### Repository Dispatch Events

Each workflow in `_service_admin_seed/.github/workflows/` corresponds to a specific operation type:

| Dispatch Event Type | Workflow File | Purpose |
|---------------------|---------------|---------|
| `create-power-platform-environment` | `create-power-platform-environment.yml` | Create new PP environment |
| `ensure-power-platform-environment` | `ensure-power-platform-environment.yml` | Ensure PP environment exists |
| `ensure-entraid-app-registration` | `ensure-entraid-app-registration.yml` | Manage app registrations |
| `ensure-security-group` | `ensure-security-group.yml` | Manage security groups |
| `ensure-maker` | `ensure-maker.yml` | Manage maker permissions |
| `ensure-environment-api-connection` | `ensure-environment-api-connection.yml` | Manage API connections |
| `ensure-business-application-platform` | `ensure-business-application-platform.yml` | Configure platform |
| `ensure-entraid-tenant` | `ensure-entraid-tenant.yml` | Configure tenant |
| `ensure-repo-env-app-registration` | `ensure-repo-env-app-registration.yml` | Link repo to app reg |
| `service-admin-operation` | `service-admin-operation.yml` | General dispatch handler |

### Common Workflow Structure

All workflows follow this pattern:

```yaml
name: [operation-name]
run-name: ${{ github.event.client_payload.dispatch_payload.current_step }}:${{ github.event.client_payload.dispatch_job_id }}

on:
  repository_dispatch:
    types: [[operation-name]]

jobs:
  perform-service-operation:
    runs-on: windows-latest
    steps:
    - name: "OnFusionCoE: [operation-name] Dispatch"
      uses: fusioncoe/onfusioncoe-actions-g2/[operation-name]@v0
      with:
        client_id: ${{ vars.FUSIONCOE_SP_APPLICATION_ID }}
        client_secret: ${{ secrets.FUSIONCOE_SP_SECRET }}
        tenant_id: ${{ vars.FUSIONCOE_SP_TENANT_ID }}
        authority: ${{ vars.FUSIONCOE_SP_AUTHORITY }}
        cloud: ${{ vars.FUSIONCOE_SP_CLOUD }}
        event_path: ${{ github.event_path }}
        output_private_key: ${{ secrets.FUSIONCOE_SP_PRIVATE_KEY }}
```

**Key Points**:
- Triggered via `repository_dispatch` events
- Uses actions from `fusioncoe/onfusioncoe-actions-g2@v0`
- Accesses secrets/variables for authentication
- Passes event payload for operation details

## Data Flow

### Inbound (OnFusionCoE → Workflow)

1. **OnFusionCoE Service** determines operation needed
2. **Encrypts operation details** using libsodium
3. **Triggers workflow** via GitHub App repository_dispatch
4. **Workflow receives** encrypted payload in `github.event_path`
5. **FsnxApiClient decrypts** payload using shared encryption key
6. **Workflow executes** operation against Microsoft APIs

### Outbound (Workflow → OnFusionCoE)

1. **Operation completes** in FsnxApiClient
2. **Result payload created** (JSON format)
3. **SHA-256 hash computed** of payload
4. **Hash encrypted with RSA** using private key from `FUSIONCOE_SP_PRIVATE_KEY`
5. **HTTPS POST** to OnFusionCoE API with headers:
   - `fusionex-output-sha`: Unencrypted payload hash
   - `fusionex-auth-rsa-sha`: Encrypted payload hash (signature)
6. **OnFusionCoE verifies**:
   - Payload integrity (hash matches)
   - Authenticity (signature decrypts correctly with public key)
7. **Result processed** if verification successful

## Extensibility

### Adding New Operations

OnFusionCoE can add new operations by:

1. **Creating new action** in `onfusioncoe-actions-g2` repository
2. **Updating service** to trigger new dispatch event type
3. **OnFusionCoE adds workflow** to customer's `_service_admin_seed` repository

**Customer involvement**: None required - workflows automatically updated

### Custom Workflows

Customers **should not** modify workflow files as they are managed by OnFusionCoE and may be overwritten during service updates.

For custom automation needs, contact your OnFusionCoE service administrator.

## Monitoring and Observability

### Customer Visibility

✅ **GitHub Actions Logs**: Complete execution logs in your repository's Actions tab
✅ **Entra ID Sign-in Logs**: Service principal authentication events
✅ **Entra ID Audit Logs**: Resource changes (app registrations, groups, etc.)
✅ **Power Platform Audit Logs**: Environment and resource modifications

### OnFusionCoE Service Logs

The OnFusionCoE service maintains orchestration logs for:
- Workflow trigger events
- Result verification status
- Overall process state

Access service logs and monitoring through the [OnFusionCoE Portal](https://devops.onfusioncoe.com), or contact your OnFusionCoE administrator for service-level logs and metrics.

## Compliance and Governance

### Data Residency

- **Credentials**: Stored in GitHub (data residency based on GitHub region)
- **Execution**: GitHub Actions runs in GitHub's infrastructure
- **Microsoft Resources**: Reside in your Microsoft cloud tenant/subscription

### Audit Trail

Complete audit trail across multiple systems:
1. **OnFusionCoE Service**: Orchestration decisions and triggers
2. **GitHub Actions**: Workflow execution history
3. **Entra ID**: Authentication and authorization events
4. **Power Platform**: Resource creation and modification

### Compliance Certifications

OnFusionCoE supports deployments in:
- Commercial Cloud (Public)
- GCC (Government Community Cloud)
- GCC High
- DoD (Department of Defense)

Consult your OnFusionCoE administrator for specific compliance certifications.

## Troubleshooting Architecture Issues

### Workflow Not Triggering

**Possible causes**:
- OnFusionCoE GitHub App not installed or missing permissions
- Repository dispatch events blocked by organization policies
- Service connectivity issues

**Check**: GitHub Actions tab for recent runs, organization app installation settings

### Authentication Failures

**Possible causes**:
- Service principal credentials incorrect or expired
- Required API permissions not granted
- Service principal not registered as PP Management App

**Check**: Entra ID sign-in logs, workflow execution logs, API permission status

### Output Verification Failures

**Possible causes**:
- `FUSIONCOE_SP_PRIVATE_KEY` missing or corrupted
- Key pair rotation in progress
- Network connectivity issues

**Check**: GitHub Secrets presence, contact OnFusionCoE administrator for key status

## Additional Resources

- [SECURITY.md](./SECURITY.md) - Detailed security architecture
- [WORKFLOWS.md](./WORKFLOWS.md) - Individual workflow documentation
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues and solutions
- [OnFusionCoE Actions Repository](https://github.com/fusioncoe/onfusioncoe-actions-g2/tree/v0) - Action implementation details

---

**Last Updated**: November 12, 2025  
**Document Version**: 1.0
