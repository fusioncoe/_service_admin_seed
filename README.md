# OnFusionCoE Service Admin Repository

> **Important:** This repository is automatically created and managed by OnFusionCoE. Do not remove this repository.

## Overview

This repository is part of **OnFusionCoE** - a DevOps-as-a-Service platform that provides automated Power Platform lifecycle management while maintaining strict security and customer data sovereignty.

OnFusionCoE orchestrates various DevOps and ALM (Application Lifecycle Management) actions through a backend service that triggers GitHub Actions workflows via repository dispatch events. The workflows follow an "Ensure" pattern, which provisions or updates resources as necessary to maintain them in a ready state.

### Security-First Architecture

OnFusionCoE follows a **zero-trust security model** where your credentials never leave your GitHub environment:

- **Customer Control**: All service principal credentials remain exclusively in your GitHub repository secrets
- **Service Isolation**: The OnFusionCoE service orchestrates workflows without ever accessing your secrets
- **Secure Proxy**: GitHub Actions serve as authenticated proxies between OnFusionCoE and your Microsoft cloud resources
- **Complete Audit Trail**: All operations logged in your GitHub Actions run history
- **Revocable Access**: You maintain full control over permissions and can revoke access at any time

The workflows in this repository use actions from [`fusioncoe/onfusioncoe-actions-g2`](https://github.com/fusioncoe/onfusioncoe-actions-g2/tree/v0), which serve as the secure execution layer for OnFusionCoE operations.

## What This Repository Does

This service admin repository provides automated workflows for:

- **Power Platform Environment Management** - Create and configure Power Platform environments
- **Entra ID Integration** - Manage app registrations and tenant configurations
- **Security & Access Control** - Configure security groups and maker permissions
- **API Connections** - Set up and manage environment API connections
- **Business Application Platform** - Ensure platform readiness for solution development

## Prerequisites

Before the workflows in this repository can function, you need to:

1. **Install the OnFusionCoE GitHub Application** in your GitHub organization
2. **Create an Entra ID App Registration** in your tenant (no Azure subscription required)
3. **Register as Power Platform Management App** - Critical for provisioning environments and connections
4. **Configure Repository Variables and Secrets** (see Setup section below)

> **Important:** API permissions alone are not sufficient. You must also register the service principal as a Power Platform Management App to enable provisioning of Power Platform resources (environments, Dataverse, connections, etc.). See the [Setup Guide](./docs/SETUP.md) for details.

## Quick Start

### 1. Create Entra ID App Registration

Create a service principal in your Entra ID tenant where your Power Platform development will take place. This service principal needs appropriate permissions to manage:

- Power Platform environments
- Entra ID app registrations
- Security groups
- API connections

**Critical:** After creating the app registration and configuring API permissions, you must also register it as a Power Platform Management App using PowerShell. Without this registration, the service cannot provision Power Platform resources.

> **No Azure subscription required** - App registrations are tenant-level resources in Entra ID.

See [Step 2.1 in the Setup Guide](./docs/SETUP.md#step-21-register-as-power-platform-management-app) for detailed instructions.

**Reference:** [Create a service principal in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal)

### 2. Configure Repository Settings

OnFusionCoE automatically creates repository environment variables and secrets as stubs. You need to populate them with your service principal details:

#### Required Variables (Settings → Secrets and variables → Actions → Variables)

- `FUSIONCOE_SP_APPLICATION_ID` - The Application (client) ID from your app registration
- `FUSIONCOE_SP_TENANT_ID` - Your Azure tenant ID
- `FUSIONCOE_SP_AUTHORITY` - The authority URL (e.g., `https://login.microsoftonline.com/`)
- `FUSIONCOE_SP_CLOUD` - The cloud environment (e.g., `Public`, `GCC`, `GCC High`)

#### Required Secrets (Settings → Secrets and variables → Actions → Secrets)

- `FUSIONCOE_SP_SECRET` - The client secret from your app registration
- `FUSIONCOE_SP_PRIVATE_KEY` - Private key for workflow output authentication (automatically managed by OnFusionCoE)

> **Note:** The `FUSIONCOE_SP_PRIVATE_KEY` is part of a public/private key pair used to cryptographically sign workflow outputs sent back to the OnFusionCoE service. This ensures data integrity and authenticates that outputs originate from your repository. The key pair is automatically created and rotated daily by OnFusionCoE - no manual configuration required.

### 3. Automated Setup Script

A PowerShell script is available in the `scripts/` directory to automate the entire configuration process, including the critical Power Platform Management App registration.

**The script automatically installs all required PowerShell modules** - no manual installation needed!

```powershell
# Run interactively
.\scripts\Set-OnFusionCoEConfig.ps1

# Or with parameters for automation
.\scripts\Set-OnFusionCoEConfig.ps1 -TenantId "your-tenant-id" -GitHubOrg "your-org"
```

See [scripts/README.md](./scripts/README.md) and [SETUP.md](./docs/SETUP.md) for detailed setup instructions.

## How It Works

1. The OnFusionCoE backend service orchestrates DevOps operations based on your Power Platform development activities
2. When resources need to be provisioned or updated, the service triggers workflows in this repository via `repository_dispatch` events
3. Workflows authenticate using your configured service principal
4. The corresponding action from `fusioncoe/onfusioncoe-actions-g2` executes the operation
5. Results are reported back to the OnFusionCoE service

## Workflows

This repository includes the following workflows:

| Workflow | Purpose | Trigger Type |
|----------|---------|--------------|
| `service-admin-operation.yml` | General service dispatch handler | `service-admin-operation` |
| `create-power-platform-environment.yml` | Creates new Power Platform environments | `create-power-platform-environment` |
| `ensure-business-application-platform.yml` | Ensures business application platform readiness | `ensure-business-application-platform` |
| `ensure-entraid-app-registration.yml` | Manages Entra ID app registrations | `ensure-entraid-app-registration` |
| `ensure-entraid-tenant.yml` | Configures Entra ID tenant settings | `ensure-entraid-tenant` |
| `ensure-environment-api-connection.yml` | Manages API connections in environments | `ensure-environment-api-connection` |
| `ensure-maker.yml` | Configures Power Platform maker permissions | `ensure-maker` |
| `ensure-power-platform-environment.yml` | Ensures Power Platform environment exists | `ensure-power-platform-environment` |
| `ensure-repo-env-app-registration.yml` | Manages repository environment app registrations | `ensure-repo-env-app-registration` |
| `ensure-security-group.yml` | Manages Entra ID security groups | `ensure-security-group` |

For detailed information about each workflow, see [WORKFLOWS.md](./docs/WORKFLOWS.md).

## Documentation

- [Quick Start Guide](./docs/QUICKSTART.md) - Get set up in 5 minutes
- [Setup Guide](./docs/SETUP.md) - Detailed setup and configuration instructions
- [Architecture Overview](./docs/ARCHITECTURE.md) - System architecture and component interaction
- [Workflow Reference](./docs/WORKFLOWS.md) - Complete workflow documentation
- [API Permissions](./docs/API_PERMISSIONS.md) - Required permissions and security configuration
- [Security Architecture](./docs/SECURITY.md) - Security mechanisms and cryptographic signing
- [Troubleshooting](./docs/TROUBLESHOOTING.md) - Common issues and solutions

## Support

For issues or questions about OnFusionCoE:

- Review the documentation in the `docs/` directory
- Check workflow run logs in the Actions tab
- Contact your OnFusionCoE service administrator

## Important Notes

- **Do not delete this repository** - It is required for OnFusionCoE to function properly
- **Do not modify workflow files** - They are managed by OnFusionCoE and may be updated automatically
- **Protect your secrets** - Never commit service principal secrets to the repository
- All workflows run on `windows-latest` GitHub-hosted runners

---

**Repository Type:** Service Admin Template  
**Created by:** OnFusionCoE  
**Last Updated:** November 12, 2025
