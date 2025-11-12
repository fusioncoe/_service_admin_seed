<#
.SYNOPSIS
    Configures OnFusionCoE Service Admin repository with Azure service principal credentials.

.DESCRIPTION
    This script helps automate the setup of the OnFusionCoE Service Admin repository by:
    - Creating or using an existing Azure/Entra ID app registration
    - Configuring required API permissions (Microsoft Graph and Power Platform)
    - Registering the app as a Power Platform Management App (requires user credentials)
    - Creating a client secret
    - Setting GitHub repository variables and secrets
    
    The script can run interactively or with parameters for automation.
    
    IMPORTANT: The Power Platform Management App registration (New-PowerAppManagementApp) 
    requires user credentials. You must authenticate with a user account, not a service principal.

.PARAMETER TenantId
    The Azure tenant ID where the app registration will be created.

.PARAMETER ApplicationId
    (Optional) Use an existing app registration instead of creating a new one.

.PARAMETER ApplicationName
    Name for the new app registration. Default: "OnFusionCoE-ServicePrincipal"

.PARAMETER GitHubOrg
    GitHub organization name where the repository exists.

.PARAMETER GitHubRepo
    GitHub repository name (typically "_service_admin_seed").

.PARAMETER GitHubToken
    GitHub Personal Access Token with repo admin permissions.
    If not provided, the script will attempt to use GitHub CLI (gh).

.PARAMETER Cloud
    Target cloud environment. Valid values: Public, GCC, GCC High, DoD
    Default: Public

.PARAMETER SkipPermissions
    Skip configuring API permissions (use if you want to configure manually).

.PARAMETER SkipPowerPlatformRegistration
    Skip registering the app as a Power Platform Management App.

.PARAMETER SkipGitHub
    Skip configuring GitHub variables and secrets (output values to console instead).

.PARAMETER SecretExpirationMonths
    Number of months until the client secret expires. Default: 12

.EXAMPLE
    .\Set-OnFusionCoEConfig.ps1
    
    Runs interactively, prompting for all required information.

.EXAMPLE
    .\Set-OnFusionCoEConfig.ps1 -TenantId "12345678-90ab-cdef-1234-567890abcdef" -GitHubOrg "myorg" -Cloud "Public"
    
    Creates app registration in specified tenant and configures GitHub repository.

.EXAMPLE
    .\Set-OnFusionCoEConfig.ps1 -ApplicationId "a1b2c3d4-e5f6-7890-abcd-ef1234567890" -SkipPermissions -GitHubOrg "myorg"
    
    Uses existing app registration and skips permission configuration.

.EXAMPLE
    .\Set-OnFusionCoEConfig.ps1 -TenantId "12345678-90ab-cdef-1234-567890abcdef" -Cloud "GCC" -GitHubOrg "myorg"
    
    Creates app registration for US Government Cloud (GCC).

.NOTES
    Requirements:
    - PowerShell 7.0+ (or Windows PowerShell 5.1+)
    - Microsoft.Graph.Authentication module (Install-Module -Name Microsoft.Graph.Authentication)
    - Microsoft.Graph.Applications module (Install-Module -Name Microsoft.Graph.Applications)
    - Microsoft.PowerApps.Administration.PowerShell module
    - Microsoft.PowerApps.PowerShell module
    - GitHub CLI (gh) or GitHub Personal Access Token
    - Appropriate Entra ID and GitHub permissions (no Azure subscription required)
    
    Power Platform Management App Registration:
    - Requires USER credentials (not service principal)
    - You will be prompted to authenticate with your user account
    - User must have Power Platform admin permissions

    Author: OnFusionCoE Team
    Version: 2.0.0
    Last Updated: November 12, 2025
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$ApplicationId,

    [Parameter(Mandatory = $false)]
    [string]$ApplicationName = "OnFusionCoE-ServicePrincipal",

    [Parameter(Mandatory = $false)]
    [string]$GitHubOrg,

    [Parameter(Mandatory = $false)]
    [string]$GitHubRepo = "_service_admin_seed",

    [Parameter(Mandatory = $false)]
    [string]$GitHubToken,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Public", "GCC", "GCC High", "DoD")]
    [string]$Cloud = "Public",

    [Parameter(Mandatory = $false)]
    [switch]$SkipPermissions,

    [Parameter(Mandatory = $false)]
    [switch]$SkipPowerPlatformRegistration,

    [Parameter(Mandatory = $false)]
    [switch]$SkipGitHub,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 24)]
    [int]$SecretExpirationMonths = 12
)

#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.0.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.0.0" }

# Script configuration
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

# Cloud configuration mapping
$CloudConfig = @{
    "Public" = @{
        Authority = "https://login.microsoftonline.com/"
        Environment = "Global"
        PowerPlatformEndpoint = "prod"
        PowerPlatformApi = "api.powerplatform.com"
    }
    "GCC" = @{
        Authority = "https://login.microsoftonline.us/"
        Environment = "USGov"
        PowerPlatformEndpoint = "usgov"
        PowerPlatformApi = "gov.api.powerplatform.microsoft.us"
    }
    "GCC High" = @{
        Authority = "https://login.microsoftonline.us/"
        Environment = "USGovDoD"
        PowerPlatformEndpoint = "usgovhigh"
        PowerPlatformApi = "high.api.powerplatform.microsoft.us"
    }
    "DoD" = @{
        Authority = "https://login.microsoftonline.us/"
        Environment = "USGovDoD"
        PowerPlatformEndpoint = "dod"
        PowerPlatformApi = "api.powerplatform.microsoft.usdod"
    }
}

# API Permissions Configuration
# These are the required permissions for OnFusionCoE operations
$ApiPermissions = @{
    # Power Platform API (Dynamics CRM)
    # Resource App ID: c9299480-c13a-49db-a7ae-cdfe54fe0313
    "PowerPlatform" = @{
        ResourceAppId = "c9299480-c13a-49db-a7ae-cdfe54fe0313"
        ResourceAccess = @(
            @{
                # Tenant.ReadWrite.All
                Id = "640bd519-35de-4a25-994f-ae29551cc6d2"
                Type = "Role"
            }
        )
    }
    
    # Microsoft Graph
    # Resource App ID: 00000003-0000-0000-c000-000000000000
    "MicrosoftGraph" = @{
        ResourceAppId = "00000003-0000-0000-c000-000000000000"
        ResourceAccess = @(
            @{
                # User.Read (Delegated)
                Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
                Type = "Scope"
            },
            @{
                # Application.ReadWrite.All
                Id = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9"
                Type = "Role"
            },
            @{
                # Application.ReadWrite.OwnedBy
                Id = "18a4783c-866b-4cc7-a460-3d5e5662c884"
                Type = "Role"
            },
            @{
                # Directory.ReadWrite.All
                Id = "8e8e4742-1d95-4f68-9d56-6ee75648c72a"
                Type = "Role"
            },
            @{
                # Group.ReadWrite.All
                Id = "62a82d76-70ea-41e2-9197-370581804d09"
                Type = "Role"
            },
            @{
                # User.ReadWrite.All
                Id = "498476ce-e0fe-48b0-b801-37ba7e2685c6"
                Type = "Role"
            },
            @{
                # Directory.Read.All
                Id = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
                Type = "Role"
            }
        )
    }
}

#region Helper Functions

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n▶️  $Message" -ForegroundColor White
}

function Test-ModuleAvailable {
    param(
        [string]$ModuleName,
        [string]$MinimumVersion = "0.0.0"
    )
    
    $module = Get-Module -ListAvailable -Name $ModuleName | 
              Where-Object { $_.Version -ge [version]$MinimumVersion } | 
              Select-Object -First 1
    
    if (-not $module) {
        Write-Fail "Required module '$ModuleName' (version $MinimumVersion+) is not installed."
        Write-Info "Install it with: Install-Module -Name $ModuleName -MinimumVersion $MinimumVersion -Scope CurrentUser"
        return $false
    }
    return $true
}

function Test-GitHubCLI {
    try {
        $ghVersion = gh --version 2>$null
        if ($ghVersion) {
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

function Read-ValidGuid {
    param (
        [string]$Prompt
    )

    $adjustedPrompt = "`n$Prompt"

    do {
        $readOutput = Read-Host $adjustedPrompt

        if ($readOutput -match "^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$") {
            return $readOutput
        }

        $adjustedPrompt = "`nInvalid GUID format. Please try again.`n$Prompt"

    } while ($true)
}

function Get-CloudChoice {
    $prompt = "Which Azure/Power Platform Cloud?"
    
    do {
        Write-Host "`n$prompt" -ForegroundColor Cyan
        Write-Host "  1: Commercial (Public)"
        Write-Host "  2: US Government (GCC)"
        Write-Host "  3: US Government High (GCC High)"
        Write-Host "  4: US DoD"
        
        $choice = Read-Host "`nEnter the appropriate number and press enter"
        
        switch ($choice) {
            1 { return "Public" }
            2 { return "GCC" }
            3 { return "GCC High" }
            4 { return "DoD" }
        }
        
        $prompt = "Invalid choice. Which Azure/Power Platform Cloud?"
    } while ($true)
}

function Install-RequiredModule {
    param(
        [string]$ModuleName,
        [string]$MinimumVersion = "0.0.0"
    )
    
    Write-Info "Installing module: $ModuleName..."
    try {
        # Set PSGallery as trusted to avoid prompts during installation
        $galleryRepo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
        if ($galleryRepo.InstallationPolicy -ne 'Trusted') {
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
        }
        
        Install-Module -Name $ModuleName -MinimumVersion $MinimumVersion -Scope CurrentUser -Force -AllowClobber -Repository PSGallery
        Write-Success "Module $ModuleName installed successfully."
        return $true
    }
    catch {
        Write-Fail "Failed to install module $ModuleName : $_"
        return $false
    }
}

#endregion

#region Main Script

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║         OnFusionCoE Service Admin Configuration Script      ║
║                        Version 2.0.0                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

try {
    #region Step 1: Verify Prerequisites
    Write-Step "Step 1: Verifying prerequisites and installing required modules..."
    
    $requiredModules = @(
        @{ Name = "Microsoft.Graph.Authentication"; Version = "2.0.0" }
        @{ Name = "Microsoft.Graph.Applications"; Version = "2.0.0" }
    )
    
    Write-Info "Checking for required Microsoft Graph modules..."
    $allModulesAvailable = $true
    foreach ($module in $requiredModules) {
        if (-not (Test-ModuleAvailable -ModuleName $module.Name -MinimumVersion $module.Version)) {
            $allModulesAvailable = $false
            Write-Info "Module $($module.Name) is missing. Installing automatically..."
            if (-not (Install-RequiredModule -ModuleName $module.Name -MinimumVersion $module.Version)) {
                throw "Failed to install required module: $($module.Name)"
            }
        } else {
            Write-Success "Module $($module.Name) is available."
        }
    }
    
    # Check for Power Platform modules (optional for PP registration)
    if (-not $SkipPowerPlatformRegistration) {
        Write-Info "Checking for Power Platform modules..."
        $ppModules = @(
            "Microsoft.PowerApps.Administration.PowerShell",
            "Microsoft.PowerApps.PowerShell"
        )
        
        foreach ($ppModule in $ppModules) {
            if (-not (Get-Module -ListAvailable -Name $ppModule)) {
                Write-Info "Power Platform module '$ppModule' is missing. Installing automatically..."
                if (-not (Install-RequiredModule -ModuleName $ppModule)) {
                    Write-Warn "Failed to install $ppModule. Power Platform registration will be skipped."
                    $SkipPowerPlatformRegistration = $true
                    break
                }
            } else {
                Write-Success "Module $ppModule is available."
            }
        }
    }
    
    Write-Success "All required modules are installed and ready."
    
    #endregion
    
    #region Step 2: Gather Configuration
    Write-Step "Step 2: Gathering configuration..."
    
    # Get Tenant ID
    if (-not $TenantId) {
        $TenantId = Read-ValidGuid -Prompt "Enter your Azure Tenant ID"
    }
    Write-Info "Tenant ID: $TenantId"
    
    # Get Cloud Environment
    if (-not $PSBoundParameters.ContainsKey('Cloud')) {
        $Cloud = Get-CloudChoice
    }
    Write-Info "Cloud Environment: $Cloud"
    
    $cloudSettings = $CloudConfig[$Cloud]
    Write-Info "Authority: $($cloudSettings.Authority)"
    Write-Info "Power Platform Endpoint: $($cloudSettings.PowerPlatformEndpoint)"
    
    # Get GitHub Configuration
    if (-not $SkipGitHub) {
        if (-not $GitHubOrg) {
            $GitHubOrg = Read-Host "`nEnter your GitHub organization name"
        }
        Write-Info "GitHub Org: $GitHubOrg"
        Write-Info "GitHub Repo: $GitHubRepo"
        
        # Check for GitHub CLI or Token
        if (-not $GitHubToken) {
            if (Test-GitHubCLI) {
                Write-Success "GitHub CLI detected. Will use 'gh' for repository configuration."
                $useGitHubCLI = $true
            } else {
                Write-Warn "GitHub CLI not found."
                $GitHubToken = Read-Host "Enter your GitHub Personal Access Token (or press Enter to skip GitHub configuration)" -AsSecureString
                if ($GitHubToken.Length -eq 0) {
                    Write-Warn "No GitHub token provided. GitHub configuration will be skipped."
                    $SkipGitHub = $true
                }
            }
        }
    }
    
    #endregion
    
    #region Step 3: Connect to Microsoft Graph
    Write-Step "Step 3: Connecting to Microsoft Graph..."
    
    $graphEnvironment = $cloudSettings.Environment
    Write-Info "Connecting to Microsoft Graph Environment: $graphEnvironment"
    
    # Define required scopes for app registration management
    $scopes = @(
        "Application.ReadWrite.All",
        "Directory.Read.All"
    )
    
    try {
        Connect-MgGraph -Environment $graphEnvironment -TenantId $TenantId -Scopes $scopes -ErrorAction Stop | Out-Null
        Write-Success "Successfully connected to Microsoft Graph."
        
        $context = Get-MgContext
        Write-Info "Logged in as: $($context.Account)"
        Write-Info "Tenant ID: $($context.TenantId)")
    }
    catch {
        throw "Failed to connect to Microsoft Graph: $_"
    }
    
    #endregion
    
    #region Step 4: Create or Get App Registration
    Write-Step "Step 4: Configuring App Registration..."
    
    $appRegistration = $null
    $isNewApp = $false
    
    if ($ApplicationId) {
        # Use existing application
        Write-Info "Looking for existing application: $ApplicationId"
        try {
            $appRegistration = Get-MgApplication -Filter "appId eq '$ApplicationId'" -ErrorAction Stop
            if (-not $appRegistration) {
                throw "Application with ID $ApplicationId not found"
            }
            Write-Success "Found existing application: $($appRegistration.DisplayName)"
        }
        catch {
            throw "Application with ID $ApplicationId not found: $_"
        }
    }
    else {
        # Create new application
        Write-Info "Creating new app registration: $ApplicationName"
        
        if ($PSCmdlet.ShouldProcess($ApplicationName, "Create App Registration")) {
            try {
                $appRegistration = New-MgApplication -DisplayName $ApplicationName -SignInAudience "AzureADMyOrg" -ErrorAction Stop
                $isNewApp = $true
                Write-Success "Created app registration: $($appRegistration.DisplayName)"
                Write-Info "Application (client) ID: $($appRegistration.AppId)"
            }
            catch {
                throw "Failed to create app registration: $_"
            }
        }
    }
    
    $ApplicationId = $appRegistration.AppId
    
    #endregion
    
    #region Step 5: Configure API Permissions
    if (-not $SkipPermissions -and $isNewApp) {
        Write-Step "Step 5: Configuring API permissions..."
        
        if ($PSCmdlet.ShouldProcess($ApplicationName, "Configure API Permissions")) {
            try {
                # Build required resource access using Microsoft Graph SDK format
                $requiredResourceAccess = @()
                
                foreach ($api in $ApiPermissions.Keys) {
                    $resourceAccess = @()
                    foreach ($permission in $ApiPermissions[$api].ResourceAccess) {
                        $resourceAccess += @{
                            Id = $permission.Id
                            Type = $permission.Type
                        }
                    }
                    
                    $requiredResourceAccess += @{
                        ResourceAppId = $ApiPermissions[$api].ResourceAppId
                        ResourceAccess = $resourceAccess
                    }
                }
                
                # Update the application with required permissions
                $params = @{
                    RequiredResourceAccess = $requiredResourceAccess
                }
                Update-MgApplication -ApplicationId $appRegistration.Id -BodyParameter $params -ErrorAction Stop
                
                Write-Success "API permissions configured successfully."
                Write-Warn "IMPORTANT: You must grant admin consent in the Azure Portal:"
                Write-Info "  1. Go to Azure Portal > Entra ID > App registrations"
                Write-Info "  2. Find your app: $ApplicationName"
                Write-Info "  3. Go to API permissions"
                Write-Info "  4. Click 'Grant admin consent for [Your Tenant]'"
                
                $grantConsent = Read-Host "`nPress Enter after granting admin consent, or type 'skip' to continue without granting"
                
            }
            catch {
                Write-Fail "Failed to configure API permissions: $_"
                Write-Warn "You may need to configure permissions manually in the Azure Portal."
            }
        }
    }
    elseif (-not $SkipPermissions) {
        Write-Info "Using existing app - skipping permission configuration."
        Write-Warn "Ensure the app has all required permissions configured."
    }
    else {
        Write-Info "Skipping API permission configuration (SkipPermissions flag set)."
    }
    
    #endregion
    
    #region Step 6: Create Client Secret
    Write-Step "Step 6: Creating client secret..."
    
    if ($PSCmdlet.ShouldProcess($ApplicationName, "Create Client Secret")) {
        try {
            $secretName = "OnFusionCoE-Secret-$(Get-Date -Format 'yyyyMMdd')"
            $secretEndDate = (Get-Date).AddMonths($SecretExpirationMonths)
            
            # Create password credential using Microsoft Graph
            $passwordCredential = @{
                displayName = $secretName
                endDateTime = $secretEndDate
            }
            
            $secret = Add-MgApplicationPassword -ApplicationId $appRegistration.Id -PasswordCredential $passwordCredential -ErrorAction Stop
            
            Write-Success "Client secret created successfully."
            Write-Warn "IMPORTANT: Save this secret value - you won't be able to see it again!"
            Write-Host "`nClient Secret Value: " -NoNewline -ForegroundColor Yellow
            Write-Host $secret.SecretText -ForegroundColor White
            Write-Info "Secret expires on: $($secretEndDate.ToString('yyyy-MM-dd'))"
            Write-Warn "Set a calendar reminder to rotate this secret before expiration!"
            
            $clientSecret = $secret.SecretText
            
            Read-Host "`nPress Enter after you have saved the secret value"
        }
        catch {
            throw "Failed to create client secret: $_"
        }
    }
    
    #endregion
    
    #region Step 7: Register as Power Platform Management App
    if (-not $SkipPowerPlatformRegistration) {
        Write-Step "Step 7: Registering as Power Platform Management App..."
        
        Write-Warn "IMPORTANT: Power Platform Management App registration requires USER credentials."
        Write-Info "You will be prompted to sign in with your user account (not service principal)."
        Write-Info "Your user account must have Power Platform admin permissions."
        
        $proceed = Read-Host "`nProceed with Power Platform registration? (Y/N)"
        
        if ($proceed -eq 'Y' -or $proceed -eq 'y') {
            try {
                # Import Power Platform modules
                Import-Module Microsoft.PowerApps.Administration.PowerShell -ErrorAction Stop
                Import-Module Microsoft.PowerApps.PowerShell -ErrorAction Stop
                
                $ppEndpoint = $cloudSettings.PowerPlatformEndpoint
                
                Write-Info "Connecting to Power Platform ($ppEndpoint)..."
                Write-Info "Please sign in with your USER credentials in the popup window..."
                
                # Connect to Power Platform with user credentials
                Add-PowerAppsAccount -Endpoint $ppEndpoint -TenantID $TenantId -ErrorAction Stop
                
                Write-Success "Connected to Power Platform."
                
                # Check for existing management apps
                Write-Info "Checking for existing Power Platform management apps..."
                $existingMgmtApps = Get-PowerAppManagementApps -ErrorAction SilentlyContinue
                
                if ($existingMgmtApps -and $existingMgmtApps.value) {
                    $appCount = $existingMgmtApps.value.Count
                    Write-Info "Found $appCount existing management app registration(s):"
                    foreach ($mgmtApp in $existingMgmtApps.value) {
                        Write-Info "  - $($mgmtApp.ApplicationId)"
                    }
                    
                    # Check if our app is already registered
                    if ($existingMgmtApps.value.ApplicationId -contains $ApplicationId) {
                        Write-Success "Application $ApplicationId is already registered as a Power Platform Management App."
                    }
                    else {
                        $register = Read-Host "`nRegister this app ($ApplicationId) as a Power Platform Management App? (Y/N)"
                        if ($register -eq 'Y' -or $register -eq 'y') {
                            New-PowerAppManagementApp -ApplicationId $ApplicationId -ErrorAction Stop
                            Write-Success "Successfully registered as Power Platform Management App."
                        }
                    }
                }
                else {
                    Write-Info "No existing management apps found. Registering this application..."
                    New-PowerAppManagementApp -ApplicationId $ApplicationId -ErrorAction Stop
                    Write-Success "Successfully registered as Power Platform Management App."
                }
            }
            catch {
                Write-Fail "Failed to register as Power Platform Management App: $_"
                Write-Warn "You may need to complete this step manually."
                Write-Info "Run: New-PowerAppManagementApp -ApplicationId $ApplicationId"
            }
        }
        else {
            Write-Info "Skipping Power Platform Management App registration."
        }
    }
    else {
        Write-Info "Skipping Power Platform Management App registration (flag set)."
    }
    
    #endregion
    
    #region Step 8: Configure GitHub Repository
    if (-not $SkipGitHub) {
        Write-Step "Step 8: Configuring GitHub repository..."
        
        $variables = @{
            "FUSIONCOE_SP_APPLICATION_ID" = $ApplicationId
            "FUSIONCOE_SP_TENANT_ID" = $TenantId
            "FUSIONCOE_SP_AUTHORITY" = $cloudSettings.Authority
            "FUSIONCOE_SP_CLOUD" = $Cloud
        }
        
        $secrets = @{
            "FUSIONCOE_SP_SECRET" = $clientSecret
        }
        
        if ($useGitHubCLI) {
            Write-Info "Using GitHub CLI to configure repository..."
            
            $repo = "$GitHubOrg/$GitHubRepo"
            
            # Set variables
            foreach ($var in $variables.Keys) {
                try {
                    gh variable set $var --body $variables[$var] --repo $repo 2>&1 | Out-Null
                    Write-Success "Set variable: $var"
                }
                catch {
                    Write-Fail "Failed to set variable $var : $_"
                }
            }
            
            # Set secrets
            foreach ($sec in $secrets.Keys) {
                try {
                    $secrets[$sec] | gh secret set $sec --repo $repo 2>&1 | Out-Null
                    Write-Success "Set secret: $sec"
                }
                catch {
                    Write-Fail "Failed to set secret $sec : $_"
                }
            }
            
            Write-Success "GitHub repository configured successfully."
        }
        else {
            Write-Warn "GitHub CLI not available. Please configure the following manually:"
            Write-Host "`nRepository: $GitHubOrg/$GitHubRepo" -ForegroundColor Cyan
            Write-Host "`nVariables (Settings → Secrets and variables → Actions → Variables):" -ForegroundColor Cyan
            foreach ($var in $variables.Keys) {
                Write-Host "  $var = $($variables[$var])"
            }
            Write-Host "`nSecrets (Settings → Secrets and variables → Actions → Secrets):" -ForegroundColor Cyan
            foreach ($sec in $secrets.Keys) {
                Write-Host "  $sec = [Secret Value]"
            }
        }
    }
    else {
        Write-Info "Skipping GitHub configuration (flag set)."
    }
    
    #endregion
    
    #region Step 9: Summary
    Write-Step "Configuration Summary"
    
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                   Configuration Complete!                   ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green
    
    Write-Host "Azure Configuration:" -ForegroundColor Cyan
    Write-Host "  Tenant ID:           $TenantId"
    Write-Host "  Application ID:      $ApplicationId"
    Write-Host "  Application Name:    $($appRegistration.DisplayName)"
    Write-Host "  Cloud Environment:   $Cloud"
    Write-Host "  Authority:           $($cloudSettings.Authority)"
    Write-Host ""
    
    if (-not $SkipGitHub) {
        Write-Host "GitHub Configuration:" -ForegroundColor Cyan
        Write-Host "  Organization:        $GitHubOrg"
        Write-Host "  Repository:          $GitHubRepo"
        Write-Host ""
    }
    
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. ✅ Grant admin consent for API permissions (if not done already)"
    Write-Host "  2. ✅ Verify GitHub variables and secrets are set correctly"
    Write-Host "  3. ✅ Set calendar reminder for secret expiration: $($secretEndDate.ToString('yyyy-MM-dd'))"
    Write-Host "  4. ✅ Test the configuration by triggering a workflow"
    Write-Host ""
    
    # Return configuration object
    return @{
        TenantId = $TenantId
        ApplicationId = $ApplicationId
        ApplicationName = $appRegistration.DisplayName
        Cloud = $Cloud
        Authority = $cloudSettings.Authority
        Environment = $cloudSettings.Environment
        PowerPlatformEndpoint = $cloudSettings.PowerPlatformEndpoint
        GitHubOrg = $GitHubOrg
        GitHubRepo = $GitHubRepo
        SecretExpirationDate = $secretEndDate
    }
}
catch {
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                    Configuration Failed                     ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Red
    
    Write-Fail "Error: $_"
    Write-Info "Please review the error message and try again."
    Write-Info "For help, see: docs/TROUBLESHOOTING.md"
    
    throw
}

#endregion
