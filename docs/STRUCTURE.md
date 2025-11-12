# Repository Structure

This document provides an overview of the OnFusionCoE Service Admin repository structure.

## Directory Tree

```
_service_admin_seed/
├── .github/
│   └── workflows/              # GitHub Actions workflows
│       ├── service-admin-operation.yml
│       ├── create-power-platform-environment.yml
│       ├── ensure-business-application-platform.yml
│       ├── ensure-entraid-app-registration.yml
│       ├── ensure-entraid-tenant.yml
│       ├── ensure-environment-api-connection.yml
│       ├── ensure-maker.yml
│       ├── ensure-power-platform-environment.yml
│       ├── ensure-repo-env-app-registration.yml
│       └── ensure-security-group.yml
│
├── docs/                       # Documentation
│   ├── README.md              # Documentation index
│   ├── QUICKSTART.md          # 5-minute setup guide
│   ├── SETUP.md               # Detailed setup instructions
│   ├── WORKFLOWS.md           # Workflow reference
│   └── TROUBLESHOOTING.md     # Problem resolution guide
│
├── scripts/                    # Helper scripts
│   ├── README.md              # Scripts documentation
│   └── Set-OnFusionCoEConfig.ps1  # PowerShell configuration helper
│
├── .gitignore                 # Git ignore rules
├── CONTRIBUTING.md            # Contribution guidelines
└── README.md                  # Main repository readme
```

## File Descriptions

### Root Level

| File | Purpose |
|------|---------|
| `README.md` | Main repository documentation, overview, and quick start |
| `CONTRIBUTING.md` | Guidelines for contributing to documentation and scripts |
| `.gitignore` | Prevents committing sensitive files and local configurations |

### .github/workflows/

All workflow files follow a consistent pattern and are triggered by repository dispatch events from the OnFusionCoE service.

| Workflow File | Trigger Type | Purpose |
|---------------|--------------|---------|
| `service-admin-operation.yml` | `service-admin-operation` | General service dispatch handler |
| `create-power-platform-environment.yml` | `create-power-platform-environment` | Create new Power Platform environments |
| `ensure-business-application-platform.yml` | `ensure-business-application-platform` | Ensure platform readiness |
| `ensure-entraid-app-registration.yml` | `ensure-entraid-app-registration` | Manage app registrations |
| `ensure-entraid-tenant.yml` | `ensure-entraid-tenant` | Configure tenant settings |
| `ensure-environment-api-connection.yml` | `ensure-environment-api-connection` | Manage API connections |
| `ensure-maker.yml` | `ensure-maker` | Configure maker permissions |
| `ensure-power-platform-environment.yml` | `ensure-power-platform-environment` | Ensure environment exists |
| `ensure-repo-env-app-registration.yml` | `ensure-repo-env-app-registration` | Manage repo environment app registrations |
| `ensure-security-group.yml` | `ensure-security-group` | Manage security groups |

### docs/

Comprehensive documentation for all aspects of the repository.

| Document | Audience | Content |
|----------|----------|---------|
| `README.md` | All users | Documentation index and navigation guide |
| `QUICKSTART.md` | First-time users | 5-minute setup checklist |
| `SETUP.md` | Users setting up | Detailed configuration instructions |
| `WORKFLOWS.md` | All users | Complete workflow reference |
| `TROUBLESHOOTING.md` | Users with issues | Problem resolution and debugging |

### scripts/

Helper scripts and automation tools.

| File | Status | Purpose |
|------|--------|---------|
| `README.md` | Complete | Scripts documentation and usage guide |
| `Set-OnFusionCoEConfig.ps1` | Placeholder | PowerShell helper for automated setup |

## Configuration Locations

### GitHub Repository Settings

Configure these through the GitHub web interface:

**Variables** (`Settings → Secrets and variables → Actions → Variables`):

- `FUSIONCOE_SP_APPLICATION_ID`
- `FUSIONCOE_SP_TENANT_ID`
- `FUSIONCOE_SP_AUTHORITY`
- `FUSIONCOE_SP_CLOUD`

**Secrets** (`Settings → Secrets and variables → Actions → Secrets`):

- `FUSIONCOE_SP_SECRET`
- `FUSIONCOE_SP_PRIVATE_KEY`

### Azure Configuration

Configure these in the Azure Portal:

- App registration (Azure Active Directory → App registrations)
- API permissions
- Client secrets
- Service principal assignments

## Navigation Guide

### For New Users

1. Start here: `README.md`
2. Quick setup: `docs/QUICKSTART.md`
3. Detailed setup: `docs/SETUP.md`
4. Learn workflows: `docs/WORKFLOWS.md`

### For Troubleshooting

1. Check: `docs/TROUBLESHOOTING.md`
2. Review: Workflow run logs in GitHub Actions tab
3. Verify: `docs/SETUP.md` configuration steps

### For Understanding Operations

1. Overview: `docs/WORKFLOWS.md`
2. Details: Individual workflow files in `.github/workflows/`
3. Execution: GitHub Actions tab

### For Contributing

1. Guidelines: `CONTRIBUTING.md`
2. Script docs: `scripts/README.md`
3. Documentation index: `docs/README.md`

## Repository Management

### What Can Be Modified

✅ Allowed:

- Documentation files in `docs/`
- Helper scripts in `scripts/`
- `.gitignore` for local needs
- `CONTRIBUTING.md` for team processes

### What Should NOT Be Modified

❌ Not recommended:

- Workflow files in `.github/workflows/` (managed by OnFusionCoE)
- Repository structure (standardized template)

## Security Considerations

### Protected Locations

These locations should NEVER contain secrets:

- All files in the repository (use GitHub Secrets instead)
- Documentation examples (use placeholders)
- Scripts (read from secure sources)

### Secure Locations

Store secrets only in:

- GitHub Repository Secrets (web UI only)
- Azure Key Vault
- Password managers
- Secure credential stores

## Monitoring Locations

### Workflow Execution

- **GitHub Actions Tab** - View all workflow runs
- **Individual Run Details** - Click any run for logs
- **Workflow Files** - See triggers and configuration

### Azure Diagnostics

- **Azure Portal → Azure AD → Sign-in logs** - Authentication attempts
- **Azure Portal → Azure AD → Audit logs** - Permission changes
- **Power Platform Admin Center** - Environment operations

## Updates and Maintenance

### Automatically Updated

OnFusionCoE may automatically update:

- Workflow files (`.github/workflows/*.yml`)
- Action versions referenced in workflows

### Manually Maintained

You are responsible for:

- Documentation updates
- Custom scripts
- Configuration values in GitHub Settings
- Azure app registration and secrets

## Size and Complexity

### Current State

- **Workflows:** 10 files
- **Documentation:** 5 comprehensive guides
- **Scripts:** 1 helper script (placeholder)
- **Total Size:** Minimal (primarily configuration and documentation)

### Expected Growth

This repository should remain small as it contains:

- Configuration workflows (not application code)
- Documentation (text files)
- Helper scripts (automation tools)

---

**Last Updated:** November 12, 2025
