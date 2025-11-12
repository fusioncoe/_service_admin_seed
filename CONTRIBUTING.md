# Contributing to OnFusionCoE Service Admin

Thank you for your interest in improving the OnFusionCoE Service Admin repository!

## Important Notes

### What You Can Contribute

✅ **You CAN contribute:**

- Documentation improvements and clarifications
- Helper scripts and automation tools
- Troubleshooting tips and solutions
- Best practices and usage examples
- Bug reports and issue documentation

### What NOT to Modify

❌ **Do NOT modify:**

- Workflow files in `.github/workflows/` - These are managed by OnFusionCoE and will be overwritten
- Core repository structure - The template structure is standardized
- Security configurations that could expose credentials

## Documentation Contributions

### Improving Existing Docs

If you find errors, unclear sections, or want to add helpful information:

1. Identify which document needs updates:
   - `README.md` - Main overview
   - `docs/QUICKSTART.md` - Quick start guide
   - `docs/SETUP.md` - Detailed setup
   - `docs/WORKFLOWS.md` - Workflow reference
   - `docs/TROUBLESHOOTING.md` - Issue resolution

2. Make your changes clearly and concisely

3. Test any commands or procedures you add

4. Update the "Last Updated" date at the bottom of the document

### Adding New Documentation

For new topics or guides:

1. Create a new file in the `docs/` directory
2. Use clear, descriptive filenames (e.g., `ADVANCED_CONFIGURATION.md`)
3. Follow the existing documentation style and formatting
4. Update `docs/README.md` to reference your new document
5. Link to it from appropriate existing documents

## Script Contributions

### Helper Scripts

If you develop useful scripts for configuration, validation, or automation:

1. Place them in the `scripts/` directory
2. Follow PowerShell best practices:
   - Include comment-based help
   - Use proper parameter validation
   - Handle errors gracefully
   - Support `-WhatIf` and `-Verbose` where appropriate

3. Update `scripts/README.md` with usage instructions

4. Test thoroughly in a non-production environment

### Script Requirements

All scripts should:

- Include clear documentation
- Validate prerequisites
- Handle errors gracefully
- Never expose secrets or credentials
- Follow security best practices

## Troubleshooting Contributions

### Documenting Solutions

If you solve a problem not covered in the troubleshooting guide:

1. Document the problem clearly:
   - What error occurred
   - What you were trying to do
   - Environment details (cloud, regions, etc.)

2. Document the solution step-by-step

3. Add it to `docs/TROUBLESHOOTING.md` in the appropriate section

4. Include error codes or log messages if relevant

## Best Practices Contributions

### Usage Examples

Share your team's best practices:

1. Create examples in documentation
2. Focus on common scenarios
3. Include context about when to use each approach
4. Explain the reasoning behind recommendations

## Code of Conduct

### Be Respectful

- Use clear, professional language
- Be helpful and supportive
- Respect different use cases and environments
- Assume good intentions

### Be Secure

- Never commit secrets or credentials
- Don't include actual tenant IDs, app IDs, or other sensitive data in examples
- Use placeholder values like `your-tenant-id` or `00000000-0000-0000-0000-000000000000`
- Review changes for potential security issues

### Be Accurate

- Test your contributions
- Verify commands and procedures work
- Update documentation when you find errors
- Use current best practices

## Submission Guidelines

### Small Changes

For minor fixes (typos, clarifications, formatting):

1. Make the change
2. Test if applicable
3. Commit with a clear message
4. Submit if using a fork/PR workflow

### Larger Changes

For significant additions or modifications:

1. Consider opening an issue first to discuss
2. Make changes in logical, related groups
3. Update all affected documentation
4. Test thoroughly
5. Document your testing

### Commit Messages

Use clear, descriptive commit messages:

```
Good: "Add troubleshooting section for GCC High environments"
Good: "Fix incorrect authority URL in QUICKSTART.md"
Good: "Add validation script for repository configuration"

Bad: "Update docs"
Bad: "Fix"
Bad: "Changes"
```

## Testing Your Contributions

### Documentation

- Read through for clarity and completeness
- Check all links work
- Verify code blocks have proper syntax
- Ensure formatting renders correctly

### Scripts

- Test in a development/test environment first
- Verify with different parameter combinations
- Test error handling
- Validate output

### Procedures

- Follow your own steps from scratch
- Test with different cloud environments if applicable
- Verify on different operating systems if relevant

## What Happens After Contributing

### Internal Teams

If you're part of an organization using OnFusionCoE:

- Share your contributions with your team
- Consider creating an internal knowledge base
- Document organization-specific configurations separately

### External Contributors

If you're contributing to a shared/public version:

- Contributions may be reviewed by OnFusionCoE team
- Changes may be incorporated into official templates
- You may be contacted for clarification

## Questions?

If you're unsure about a contribution:

- Check existing documentation first
- Review similar examples in the repository
- Ask your OnFusionCoE administrator
- Open an issue for discussion

## License

By contributing, you agree that your contributions will be licensed under the same terms as the OnFusionCoE Service Admin repository.

## Attribution

Significant contributions may be recognized in documentation or release notes (with your permission).

---

Thank you for helping improve OnFusionCoE Service Admin!

**Last Updated:** November 12, 2025
