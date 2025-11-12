# OnFusionCoE Workflow Reference

This document provides detailed information about each workflow in the Service Admin repository.

## Table of Contents

- [Overview](#overview)
- [Common Configuration](#common-configuration)
- [Workflow Details](#workflow-details)
  - [Service Admin Operation](#service-admin-operation)
  - [Create Power Platform Environment](#create-power-platform-environment)
  - [Ensure Business Application Platform](#ensure-business-application-platform)
  - [Ensure Entra ID App Registration](#ensure-entra-id-app-registration)
  - [Ensure Entra ID Tenant](#ensure-entra-id-tenant)
  - [Ensure Environment API Connection](#ensure-environment-api-connection)
  - [Ensure Maker](#ensure-maker)
  - [Ensure Power Platform Environment](#ensure-power-platform-environment)
  - [Ensure Repository Environment App Registration](#ensure-repository-environment-app-registration)
  - [Ensure Security Group](#ensure-security-group)

## Overview

All workflows in this repository follow a consistent pattern:

1. **Triggered by Repository Dispatch** - The OnFusionCoE backend service triggers workflows via GitHub's repository_dispatch API
2. **Authenticate with Service Principal** - Each workflow uses the configured Azure service principal
3. **Execute via Reusable Actions** - Work is delegated to actions in `fusioncoe/onfusioncoe-actions-g2@v0`
4. **Report Results** - Outcomes are communicated back to the OnFusionCoE service

### "Ensure" Pattern

Most workflows follow an "ensure" pattern, which means they:

- Check if the resource exists
- Create it if it doesn't exist
- Update it if it exists but doesn't match the desired state
- Leave it unchanged if it's already in the correct state

This idempotent approach allows workflows to be run repeatedly without causing errors or duplicate resources.

## Common Configuration

All workflows use the same authentication configuration:

### Input Parameters

| Parameter | Source | Purpose |
|-----------|--------|---------|
| `client_id` | `vars.FUSIONCOE_SP_APPLICATION_ID` | Azure service principal application ID |
| `client_secret` | `secrets.FUSIONCOE_SP_SECRET` | Azure service principal secret |
| `tenant_id` | `vars.FUSIONCOE_SP_TENANT_ID` | Azure tenant ID |
| `authority` | `vars.FUSIONCOE_SP_AUTHORITY` | Azure AD authority URL |
| `cloud` | `vars.FUSIONCOE_SP_CLOUD` | Target cloud environment |
| `event_path` | `github.event_path` | Path to the dispatch event payload |
| `output_private_key` | `secrets.FUSIONCOE_SP_PRIVATE_KEY` | Encryption key for sensitive outputs |

### Runtime Configuration

- **Runner:** `windows-latest`
- **Trigger:** Repository dispatch events
- **Execution:** Automated by OnFusionCoE service

## Workflow Details

### Service Admin Operation

**File:** `.github/workflows/service-admin-operation.yml`

**Purpose:** General-purpose service dispatch handler for administrative operations.

**Trigger Type:** `service-admin-operation`

**When It Runs:** This workflow serves as a catch-all for general service operations that don't fit into more specific workflow categories.

**Action:** `fusioncoe/onfusioncoe-actions-g2/process-service-repo-dispatch@v0`

**Use Cases:**

- Generic administrative tasks
- Multi-step orchestration operations
- Service health checks

---

### Create Power Platform Environment

**File:** `.github/workflows/create-power-platform-environment.yml`

**Purpose:** Creates a new Power Platform environment.

**Trigger Type:** `create-power-platform-environment`

**When It Runs:** When a new Power Platform environment needs to be provisioned for development, testing, or production purposes.

**Action:** `fusioncoe/onfusioncoe-actions-g2/create-power-platform-environment@v0`

**Use Cases:**

- Provisioning development environments for new projects
- Creating dedicated testing environments
- Setting up sandbox environments for experimentation
- Establishing production environments for solution deployment

**Typical Payload Parameters:**

- Environment name
- Environment type (Sandbox, Production, Trial)
- Region/location
- Security group assignments
- Dataverse database configuration

---

### Ensure Business Application Platform

**File:** `.github/workflows/ensure-business-application-platform.yml`

**Purpose:** Ensures the business application platform is properly configured and ready for solution development.

**Trigger Type:** `ensure-business-application-platform`

**When It Runs:** When verifying or establishing platform readiness for business application development.

**Action:** `fusioncoe/onfusioncoe-actions-g2/ensure-business-application-platform@v0`

**Use Cases:**

- Verifying platform prerequisites are met
- Configuring platform-level settings
- Ensuring required services are enabled
- Validating platform capacity and quotas

**What It Ensures:**

- Required Power Platform features are enabled
- Necessary licenses are available
- Platform capacity thresholds are met
- Integration points are configured

---

### Ensure Entra ID App Registration

**File:** `.github/workflows/ensure-entraid-app-registration.yml`

**Purpose:** Manages Entra ID (Azure AD) application registrations for solutions.

**Trigger Type:** `ensure-entraid-app-registration`

**When It Runs:** When solutions require application registrations for authentication, API access, or service-to-service communication.

**Action:** `fusioncoe/onfusioncoe-actions-g2/ensure-entraid-app-registration@v0`

**Use Cases:**

- Creating app registrations for custom applications
- Configuring authentication for Canvas/Model-driven apps
- Setting up API permissions for integrations
- Managing redirect URIs for web applications
- Configuring app roles and scopes

**What It Ensures:**

- App registration exists with correct name
- Required API permissions are configured
- Redirect URIs are properly set
- App roles and scopes match requirements
- Certificates or secrets are configured (metadata only)

---

### Ensure Entra ID Tenant

**File:** `.github/workflows/ensure-entraid-tenant.yml`

**Purpose:** Configures Entra ID tenant-level settings required for Power Platform integration.

**Trigger Type:** `ensure-entraid-tenant`

**When It Runs:** When tenant-wide configurations need to be established or verified for Power Platform operations.

**Action:** `fusioncoe/onfusioncoe-actions-g2/ensure-entraid-tenant@v0`

**Use Cases:**

- Validating tenant configuration
- Ensuring required tenant settings are enabled
- Verifying tenant-level permissions
- Checking licensing availability

**What It Ensures:**

- Tenant is properly configured for Power Platform
- Required administrative consents are granted
- Tenant-level policies align with requirements

---

### Ensure Environment API Connection

**File:** `.github/workflows/ensure-environment-api-connection.yml`

**Purpose:** Manages API connections within Power Platform environments.

**Trigger Type:** `ensure-environment-api-connection`

**When It Runs:** When solutions require API connections to external services or data sources.

**Action:** `fusioncoe/onfusioncoe-actions-g2/ensure-environment-api-connection@v0`

**Use Cases:**

- Creating connectors for SharePoint, SQL, or other data sources
- Configuring authentication for API connections
- Managing shared connections across teams
- Setting up connections for automated flows

**What It Ensures:**

- API connection exists in the target environment
- Connection uses the correct connector
- Authentication is properly configured
- Connection is in a working state

**Common Connection Types:**

- SharePoint
- SQL Server
- Office 365
- Dynamics 365
- Custom APIs
- Azure services

---

### Ensure Maker

**File:** `.github/workflows/ensure-maker.yml`

**Purpose:** Configures Power Platform maker permissions and access for users.

**Trigger Type:** `ensure-maker`

**When It Runs:** When users need to be granted or verified as makers in Power Platform environments.

**Action:** `fusioncoe/onfusioncoe-actions-g2/ensure-maker@v0`

**Use Cases:**

- Granting maker access to development teams
- Assigning environment permissions to specific users
- Managing maker roles across multiple environments
- Onboarding new team members

**What It Ensures:**

- User has maker permissions in the environment
- Appropriate security roles are assigned
- User can create and modify apps, flows, and other solutions

**Typical Security Roles:**

- Environment Maker
- System Customizer
- Basic User

---

### Ensure Power Platform Environment

**File:** `.github/workflows/ensure-power-platform-environment.yml`

**Purpose:** Ensures a Power Platform environment exists and is configured correctly.

**Trigger Type:** `ensure-power-platform-environment`

**When It Runs:** When verifying or establishing that a Power Platform environment is ready for use.

**Action:** `fusioncoe/onfusioncoe-actions-g2/ensure-power-platform-environment@v0`

**Use Cases:**

- Verifying environment existence before deployment
- Creating environments if they don't exist
- Updating environment configuration
- Ensuring environment state matches requirements

**What It Ensures:**

- Environment exists with the specified name
- Environment type is correct (Sandbox/Production)
- Dataverse database is provisioned (if required)
- Environment is in an active/ready state
- Configuration matches specified parameters

**Difference from "Create" Workflow:**

- **Create:** Explicitly creates a new environment (fails if it exists)
- **Ensure:** Creates if needed, verifies if exists, updates if configuration changed

---

### Ensure Repository Environment App Registration

**File:** `.github/workflows/ensure-repo-env-app-registration.yml`

**Purpose:** Manages app registrations specifically for repository environment integrations.

**Trigger Type:** `ensure-repo-env-app-registration`

**When It Runs:** When setting up or verifying app registrations that link repository environments with Power Platform resources.

**Action:** `fusioncoe/onfusioncoe-actions-g2/ensure-repo-env-app-registration@v0`

**Use Cases:**

- Creating service principals for CI/CD pipelines
- Configuring app registrations for GitHub environment secrets
- Managing authentication for deployment automation
- Linking repository environments to Power Platform environments

**What It Ensures:**

- App registration exists for the repository environment
- Federated credentials are configured (if using OIDC)
- API permissions support deployment operations
- Secrets or certificates are configured for authentication

**Integration Points:**

- GitHub repository environments
- Power Platform environments
- Azure service principals
- CI/CD pipelines

---

### Ensure Security Group

**File:** `.github/workflows/ensure-security-group.yml`

**Purpose:** Manages Entra ID security groups used for Power Platform access control.

**Trigger Type:** `ensure-security-group`

**When It Runs:** When security groups need to be created or verified for controlling access to environments or resources.

**Action:** `fusioncoe/onfusioncoe-actions-g2/ensure-security-group@v0`

**Use Cases:**

- Creating security groups for environment access
- Managing team-based access control
- Organizing users by project or department
- Implementing role-based access control (RBAC)

**What It Ensures:**

- Security group exists with the specified name
- Group members match requirements (if specified)
- Group is properly configured for Power Platform use

**Output:**

This workflow includes an output step that captures the security group's object ID for use in subsequent operations.

```yaml
outputs:
  object_id: The Azure object ID of the security group
```

**Common Use Cases:**

- Restricting environment access to specific teams
- Organizing makers by department
- Implementing approval workflows
- Controlling solution deployment permissions

## Monitoring Workflow Runs

### Viewing Workflow Executions

1. Navigate to the **Actions** tab in your repository
2. Select a workflow from the left sidebar
3. View individual run details, logs, and outcomes

### Understanding Run Names

Workflow runs are named using the pattern:

```
{current_step}:{dispatch_job_id}
```

or for general operations:

```
{action}:{dispatch_job_id}
```

This naming helps correlate GitHub Actions runs with OnFusionCoE service operations.

### Workflow Status

- **Success (✓):** Operation completed successfully
- **Failure (✗):** Operation encountered an error (check logs)
- **Cancelled (○):** Operation was manually cancelled or timed out
- **In Progress (◷):** Operation is currently running

## Troubleshooting Workflows

### Common Issues

#### Authentication Failures

- Verify service principal credentials in repository secrets/variables
- Check that the service principal has required permissions
- Ensure client secret hasn't expired

#### Permission Errors

- Confirm API permissions are granted in Azure
- Verify admin consent has been granted
- Check that service principal has necessary Power Platform roles

#### Timeout Issues

- Large operations may take time to complete
- Check Azure/Power Platform service health
- Review operation payload for unusually large requests

### Getting Detailed Logs

1. Click on a failed workflow run
2. Expand the job step to see detailed logs
3. Look for error messages from the OnFusionCoE action
4. Check the event payload if issues relate to input parameters

## Best Practices

### Workflow Management

- **Don't modify workflow files** - They're managed by OnFusionCoE and may be automatically updated
- **Monitor the Actions tab** - Regularly review workflow executions for errors
- **Check run history** - Understand patterns in your deployments and operations

### Security

- **Protect secrets** - Never expose service principal secrets in logs or outputs
- **Review permissions** - Periodically audit service principal permissions
- **Rotate credentials** - Update client secrets before expiration

### Operations

- **Understand "ensure" semantics** - Remember that ensure operations are idempotent
- **Review payloads** - Understand what parameters are being sent to workflows
- **Use appropriate workflows** - Choose specific workflows over generic ones when available

## Advanced Topics

### Workflow Inputs

Workflows receive their configuration through repository dispatch event payloads. The OnFusionCoE service constructs these payloads based on your operations.

Typical payload structure:

```json
{
  "client_payload": {
    "dispatch_job_id": "unique-job-identifier",
    "dispatch_payload": {
      "current_step": "operation-name",
      // Operation-specific parameters
    }
  }
}
```

### Custom Actions

All workflows delegate to reusable actions in the `fusioncoe/onfusioncoe-actions-g2` repository at version `v0`. These actions are maintained by the OnFusionCoE team and encapsulate the business logic for each operation.

### Extending Workflows

While you shouldn't modify existing workflows, you can:

- Add custom workflows that integrate with OnFusionCoE operations
- Create notification workflows that trigger on workflow completion
- Build monitoring dashboards using GitHub Actions API

---

**Last Updated:** November 12, 2025
