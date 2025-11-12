# OnFusionCoE Service Admin Documentation

Welcome to the OnFusionCoE Service Admin documentation. This directory contains comprehensive guides to help you set up, configure, and troubleshoot your OnFusionCoE Service Admin repository.

## 📚 Documentation Index

### Getting Started

- **[Quick Start Guide](./QUICKSTART.md)** - 5-minute setup guide to get running fast
  - Minimal steps to configure your repository
  - Perfect for first-time setup
  - Essential configurations only

### Setup & Configuration

- **[Setup Guide](./SETUP.md)** - Comprehensive setup instructions
  - Detailed step-by-step procedures
  - Azure/Entra ID app registration
  - API permissions configuration
  - GitHub repository configuration
  - Security best practices
  - PowerShell helper script usage

### Reference

- **[Architecture Overview](./ARCHITECTURE.md)** - System architecture and data flow
  - Zero-trust security model
  - Component interaction diagrams
  - Authentication flows
  - Workflow execution lifecycle
  - OnFusionCoE Actions integration
  - Data flow (inbound/outbound)
  - Monitoring and observability

- **[Workflow Reference](./WORKFLOWS.md)** - Complete workflow documentation
  - Detailed description of each workflow
  - Trigger types and events
  - Use cases and examples
  - Input parameters and outputs
  - "Ensure" pattern explanation

- **[API Permissions Reference](./API_PERMISSIONS.md)** - Required permissions and security
  - Complete list of required API permissions
  - Permission IDs and resource app IDs
  - Manifest format for permissions
  - Cloud-specific considerations
  - Granting admin consent
  - Power Platform Management App registration
  - Security best practices

- **[Security Architecture](./SECURITY.md)** - Security mechanisms and best practices
  - Service principal authentication
  - Workflow output signing and verification
  - Private/public key pair management
  - Data integrity and origin verification
  - Repository secrets protection
  - API permissions and least privilege
  - Compliance and auditing
  - Incident response procedures

- **[Repository Structure](./STRUCTURE.md)** - File organization and navigation

### Troubleshooting

- **[Troubleshooting Guide](./TROUBLESHOOTING.md)** - Problem resolution
  - Common authentication issues
  - Permission errors
  - Workflow execution problems
  - Configuration issues
  - Error code reference
  - Debugging tips

## 🗺️ Navigation Guide

### I'm new to OnFusionCoE

1. Start with the main [README.md](../README.md) to understand what OnFusionCoE is
2. Follow the [Quick Start Guide](./QUICKSTART.md) to get set up quickly
3. Review the [Workflow Reference](./WORKFLOWS.md) to understand what operations are available

### I'm setting up for the first time

1. Review [Quick Start Guide](./QUICKSTART.md) for a fast setup
2. Follow [Setup Guide](./SETUP.md) for detailed instructions
3. Keep [Troubleshooting Guide](./TROUBLESHOOTING.md) handy

### I'm troubleshooting an issue

1. Check [Troubleshooting Guide](./TROUBLESHOOTING.md) for your specific error
2. Review [Setup Guide](./SETUP.md) to verify your configuration
3. Consult [Workflow Reference](./WORKFLOWS.md) for workflow-specific details

### I want to understand workflows

1. Start with [Workflow Reference](./WORKFLOWS.md)
2. Check the main [README.md](../README.md) for overview
3. Review workflow files in `.github/workflows/` for technical details

## 📖 Document Summaries

### QUICKSTART.md

**Target Audience:** First-time users who want to get running quickly

**What's Inside:**

- 5-minute setup checklist
- Essential configuration steps
- Quick verification process
- Common first-time issues

**When to Use:** Initial repository setup

---

### SETUP.md

**Target Audience:** Users who want detailed setup instructions

**What's Inside:**

- Prerequisites and requirements
- Step-by-step Azure app registration creation
- API permission configuration
- Client secret management
- GitHub repository configuration
- PowerShell helper script documentation
- Security considerations
- Verification procedures

**When to Use:** First-time setup or when making configuration changes

---

### WORKFLOWS.md

**Target Audience:** Users who want to understand workflow operations

**What's Inside:**

- Overview of the "ensure" pattern
- Detailed documentation for each workflow
- Trigger types and event structure
- Use cases and examples
- Input parameters and outputs
- Monitoring and debugging guidance
- Best practices

**When to Use:** Understanding what workflows do, troubleshooting workflow issues, planning operations

---

### TROUBLESHOOTING.md

**Target Audience:** Users experiencing issues

**What's Inside:**

- Authentication troubleshooting
- Permission error resolution
- Workflow execution problems
- Configuration issue diagnosis
- Common error codes and meanings
- Debugging tips and techniques
- Support contact information

**When to Use:** When encountering errors or unexpected behavior

---

## 🔗 Related Resources

### In This Repository

- [Main README](../README.md) - Repository overview and introduction
- [Scripts Directory](../scripts/README.md) - Helper scripts and automation
- [Workflow Files](../.github/workflows/) - Actual workflow definitions

### OnFusionCoE Resources

- [OnFusionCoE Portal](https://devops.onfusioncoe.com) - Service dashboard and management
- [OnFusionCoE Actions (v0)](https://github.com/fusioncoe/onfusioncoe-actions-g2/tree/v0) - GitHub Actions execution layer
  - Secure proxy actions that run your workflows
  - FsnxApiClient implementation details
  - Architecture and security documentation

### External Resources

- [Azure Portal](https://portal.azure.com) - Manage Azure/Entra ID resources
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com) - Manage Power Platform
- [GitHub Settings](../../settings) - Configure repository settings
- [Microsoft Graph API](https://learn.microsoft.com/en-us/graph/) - API documentation

## 🆘 Getting Help

### Self-Service

1. Check the appropriate guide based on your needs (see Navigation Guide above)
2. Review workflow run logs in the Actions tab
3. Validate your configuration against the Setup Guide

### Support Channels

1. **OnFusionCoE Portal** - [https://devops.onfusioncoe.com](https://devops.onfusioncoe.com) - Service dashboard and support
2. **Documentation** - All guides in this directory
3. **Workflow Logs** - Actions tab in repository
4. **Azure Diagnostics** - Entra ID sign-in and audit logs
5. **Administrator** - Your OnFusionCoE service administrator

## 📝 Contributing

Found an issue in the documentation? Have suggestions for improvement?

- Document any custom configurations your team uses
- Share troubleshooting solutions that worked for you
- Contribute to the PowerShell helper scripts

## 🔄 Updates

This documentation is maintained alongside the OnFusionCoE service. Key sections are updated when:

- New workflows are added
- Configuration requirements change
- New features are released
- Common issues are identified

**Last Updated:** November 12, 2025

---

**Quick Links:**

- 🚀 [Quick Start](./QUICKSTART.md)
- 🔧 [Setup Guide](./SETUP.md)
- 📋 [Workflows](./WORKFLOWS.md)
- 🔍 [Troubleshooting](./TROUBLESHOOTING.md)
- 🏠 [Main README](../README.md)
