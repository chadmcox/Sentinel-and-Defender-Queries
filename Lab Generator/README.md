# Defender for Identity lab activity generator v4

This pack is designed to generate **higher-signal, more visible** lab activity in Microsoft Defender for Identity by using a mix of:

- AD password resets and attribute changes
- group membership noise
- UPN changes
- lightweight recon-style AD queries
- **SMB-style activity** using `net view` / `net use`
- **PsExec-style remote execution** from a lab workstation to a lab target host
- **SAMR-style enumeration** via `net user /domain` and `net group /domain`

## Important guardrails
- This is for **lab-only** use.
- Use a **non-DC workstation** as the source host.
- Keep the PsExec target to a **non-production lab server**.
- Use a harmless command such as `whoami` or `hostname`.
- Do not use the scripts against production or privileged accounts.

## Recommended order
1. Run `00-Check-Prereqs.ps1`
2. Run `01-Run-HighSignal-Burst.ps1`
3. Watch the MDI portal and Advanced Hunting for the activity.

## Example
```powershell
Set-Location C:\path\to\mdi_lab_scripts_v4
.\00-Check-Prereqs.ps1
.\01-Run-HighSignal-Burst.ps1 -Domain contoso.com -UseFixedAccounts
```


Default user search scopes now cover `OU=Central,DC=contoso,DC=com` and `OU=User Accounts,DC=contoso,DC=com`. Group membership helpers also target the `OU=Groups,DC=contoso,DC=com` tree and the Central subtree when relevant.


Group noise now discovers groups from the live OU tree under `OU=Groups,DC=contoso,DC=com`, `OU=Security Groups`, `OU=Distribution Groups`, `OU=CloudGroups`, and the regional `Groups` OUs under `OU=Central,DC=contoso,DC=com`, plus the tiered admin OUs.


### Added demo helpers
- `12-Honeypot-Noise.ps1` updates the honeypot account description to create lab-local activity.
- `13-Simple-Bind-Test.ps1` performs a lightweight LDAP bind test against a supplied identity and password.
- `14-Combined-Demo.ps1` runs a one-shot lab sequence using BG1/BG2/BG3, the honeypot account, and LDAP bind checks.

### Create schedule task
```powershell
$TaskName = "MDI-Lab-Random-Demo"
$ScriptPath = "C:\Lab\mdi_lab_scripts_v4\14-Combined-Demo.ps1"
$User = "contoso\mdi-lab-svc"

$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`"" `
    -WorkingDirectory "C:\Scripts\mdi_lab_scripts_v4"

$trigger = New-ScheduledTaskTrigger `
    -Daily `
    -At "06:00AM" `
    -RandomDelay (New-TimeSpan -Minutes 120)

$principal = New-ScheduledTaskPrincipal `
    -UserId $User `
    -RunLevel Highest

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Description "Runs the MDI lab demo script under the dedicated lab service account" `
    -Force
```
