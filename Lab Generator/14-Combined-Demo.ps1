param(
    [string]$Domain = (Get-ADDomain).DNSRoot,
    [string]$SourceHost = $env:COMPUTERNAME,
    [string]$HoneyToken = 'CN=honeypot,CN=Users,DC=contoso,DC=com',
    [string[]]$UserSearchBases = @(
        'OU=Central,DC=contoso,DC=com',
        'OU=User Accounts,DC=contoso,DC=com',
        'OU=Enabled Users,OU=User Accounts,DC=contoso,DC=com',
        'OU=Disabled Users,OU=User Accounts,DC=contoso,DC=com',
        'OU=DeletedUserTest,OU=User Accounts,DC=contoso,DC=com',
        'OU=bleh,OU=User Accounts,DC=contoso,DC=com',
        'OU=Contact OU,OU=User Accounts,DC=contoso,DC=com',
        'OU=CloudUsers,DC=contoso,DC=com',
        'OU=NewUsers,DC=contoso,DC=com',
        'OU=Niners,OU=User Accounts,DC=contoso,DC=com',
        'OU=Accounts,OU=Tier 0,OU=Admin,DC=contoso,DC=com',
        'OU=Accounts,OU=Tier 1,OU=Admin,DC=contoso,DC=com',
        'OU=Accounts,OU=Tier 2,OU=Admin,DC=contoso,DC=com'
    )
)

$ErrorActionPreference = 'Continue'

$targets = @('BG1','BG2','BG3')
$results = @()

foreach ($acct in $targets) {
    $pw = & "$PSScriptRoot\\02-Reset-Password.ps1" -Identity $acct -UserSearchBases $UserSearchBases
    $results += $pw

    $results += & "$PSScriptRoot\\03-Change-Attributes.ps1" -Identity $acct -Domain $Domain -UserSearchBases $UserSearchBases
    $results += & "$PSScriptRoot\\04-Group-Noise.ps1" -Identity $acct -UserSearchBases $UserSearchBases
    $results += & "$PSScriptRoot\\05-Account-Toggle.ps1" -Identity $acct -UserSearchBases $UserSearchBases
    $results += & "$PSScriptRoot\\06-UPN-Change.ps1" -Identity $acct -Domain $Domain -UserSearchBases $UserSearchBases
    $results += & "$PSScriptRoot\\07-Recon-Noise.ps1" -Domain $Domain
    $results += & "$PSScriptRoot\\08-SAMR-Noise.ps1" -Domain $Domain
    $results += & "$PSScriptRoot\\09-SMB-Noise.ps1" -Domain $Domain -SourceHost $SourceHost
    $results += & "$PSScriptRoot\\08-Login-Noise.ps1" -Identity $acct -Password $pw.Password -Domain $Domain -SourceHost $SourceHost
}

$results += & "$PSScriptRoot\\12-Honeypot-Noise.ps1" -HoneyToken $HoneyToken
$results += & "$PSScriptRoot\\13-Simple-Bind-Test.ps1" -Identity 'BG1' -Password 'P@ssw0rd!123' -Domain $Domain
$results += & "$PSScriptRoot\\13-Simple-Bind-Test.ps1" -Identity $HoneyToken -Password 'P@ssw0rd!123' -Domain $Domain

$results | ConvertTo-Json -Depth 4
