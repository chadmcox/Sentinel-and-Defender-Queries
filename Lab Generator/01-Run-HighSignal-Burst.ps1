param(
    [string]$Domain = (Get-ADDomain).DNSRoot,
    [string]$SourceHost = $env:COMPUTERNAME,
    [int]$TargetCount = 3,
    [switch]$UseFixedAccounts,
    [string[]]$FixedAccounts = @('BG1', 'BG2', 'BG3'),
    [string[]]$UserSearchBases = @('OU=Central,DC=contoso,DC=com','OU=User Accounts,DC=contoso,DC=com'),
    [string]$LogPath = "$PSScriptRoot\\mdi-activity-log-v4.csv",
    [string]$PsExecTarget = 'lab-dc01.contoso.com',
    [switch]$SkipPsExec
)

$ErrorActionPreference = 'Continue'

function Write-Log { param([string]$Message) $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; Add-Content -Path $LogPath -Value "$ts,$Message"; Write-Host $Message }
function Get-TargetAccounts {
    param([int]$Count)
    if ($UseFixedAccounts) { return $FixedAccounts }
    $users = foreach ($base in $UserSearchBases) { Get-ADUser -Filter * -SearchBase $base -Properties SamAccountName | Select-Object -ExpandProperty SamAccountName }
    return $users | Where-Object { $_ -notmatch 'krbtkt|krbtgt|Guest|Administrator|chad' } | Sort-Object { Get-Random } | Select-Object -First $Count
}

Write-Log "Starting high-signal burst from $SourceHost"
$accounts = Get-TargetAccounts -Count $TargetCount
Write-Log "Targets: $($accounts -join ', ')"
$results = @()

foreach ($acct in $accounts) {
    Write-Log "Account: $acct"
    $pw = & "$PSScriptRoot\\02-Reset-Password.ps1" -Identity $acct -UserSearchBases $UserSearchBases
    $results += $pw

    $results += & "$PSScriptRoot\\03-Change-Attributes.ps1" -Identity $acct -Domain $Domain -UserSearchBases $UserSearchBases
    $results += & "$PSScriptRoot\\04-Group-Noise.ps1" -Identity $acct -UserSearchBases $UserSearchBases
    $results += & "$PSScriptRoot\\05-Account-Toggle.ps1" -Identity $acct -UserSearchBases $UserSearchBases
    $results += & "$PSScriptRoot\\06-UPN-Change.ps1" -Identity $acct -Domain $Domain -UserSearchBases $UserSearchBases

    $results += & "$PSScriptRoot\\07-Recon-Noise.ps1" -Domain $Domain
    $results += & "$PSScriptRoot\\08-SAMR-Noise.ps1" -Domain $Domain
    $results += & "$PSScriptRoot\\09-SMB-Noise.ps1" -Domain $Domain -SourceHost $SourceHost

    if (-not $SkipPsExec) {
        $results += & "$PSScriptRoot\\10-PsExec-Noise.ps1" -TargetHost $PsExecTarget -UserName $acct -Password $pw.Password
    }
}

$results | Export-Csv -Path $LogPath -NoTypeInformation
Write-Log "Done. Log at $LogPath"
