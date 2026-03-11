# Azure interactive sign-in with PowerShell 7+ (pwsh)

**Researched:** Microsoft Learn — [Install Azure PowerShell on macOS](https://learn.microsoft.com/en-us/powershell/azure/install-azps-macos), [Sign in to Azure PowerShell interactively](https://learn.microsoft.com/en-us/powershell/azure/authenticate-interactive), [Connect-AzAccount](https://learn.microsoft.com/en-us/powershell/module/az.accounts/connect-azaccount).

## Prerequisites

- **PowerShell 7+** (`pwsh`). Check with: `pwsh -NoProfile -Command '$PSVersionTable.PSVersion'`
- Network access to Azure and PowerShell Gallery (PSGallery).

## 1. Install the Az module

The **Az** module is the rollup; installing it pulls in the modules needed to manage and connect to Azure (including `Az.Accounts`, which provides `Connect-AzAccount`).

```powershell
Install-Module -Name Az -Repository PSGallery -Force -Scope CurrentUser
```

- Use `-Scope CurrentUser` to install without needing elevation. Omit for machine-wide install.
- Run this in **pwsh** (PowerShell 7+), not Windows PowerShell 5.1, for the recommended experience.
- If prompted for NuGet provider or untrusted repository, accept/trust **PSGallery** when safe to do so.

## 2. Interactive login (sign-in)

In the same (or any new) pwsh session:

```powershell
Connect-AzAccount
```

- A browser window opens for you to sign in with your Azure/Microsoft account.
- Supports MFA; use your normal Azure AD / Microsoft Entra ID credentials.
- Sign-in is per session unless you use [context persistence](https://learn.microsoft.com/en-us/powershell/azure/context-persistence).

## 3. Verify connection

After signing in:

```powershell
Get-AzContext
```

Shows the active subscription and tenant. To list subscriptions:

```powershell
Get-AzSubscription
```

To verify access to Cognitive Services resources (e.g. your Foundry/AI resource):

```powershell
Get-AzCognitiveServicesAccount
```

## 4. Get API keys (Cognitive Services / Foundry)

To get the **API keys** for a Cognitive Services account (used for `Ocp-Apim-Subscription-Key` or `api-key` header in REST/SDK calls):

```powershell
Get-AzCognitiveServicesAccountKey -ResourceGroupName <resource-group> -Name <account-name>
```

Example for resource **open-ai-fd-lab-01** in group **open-ai-rg-lab-01**:

```powershell
Get-AzCognitiveServicesAccountKey -ResourceGroupName open-ai-rg-lab-01 -Name open-ai-fd-lab-01
```

Returns **Key1** and **Key2** (use either for API calls; Key2 is for rotation). Store keys securely; rotate via the portal or `New-AzCognitiveServicesAccountKey` if needed.

## 5. Update Az (optional)

```powershell
Update-Module -Name Az -Force
```

## References

| Topic | URL |
|-------|-----|
| Install Az on macOS | https://learn.microsoft.com/en-us/powershell/azure/install-azps-macos |
| Authenticate interactively | https://learn.microsoft.com/en-us/powershell/azure/authenticate-interactive |
| Connect-AzAccount | https://learn.microsoft.com/en-us/powershell/module/az.accounts/connect-azaccount |
| Context persistence | https://learn.microsoft.com/en-us/powershell/azure/context-persistence |
| Troubleshooting | https://learn.microsoft.com/en-us/powershell/azure/troubleshooting |
