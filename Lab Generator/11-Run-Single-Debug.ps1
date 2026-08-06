param([Parameter(Mandatory)] [string]$Identity,[string]$Domain=(Get-ADDomain).DNSRoot,[string[]]$UserSearchBases = @('OU=Central,DC=contoso,DC=com','OU=User Accounts,DC=contoso,DC=com'))
Write-Host "Debugging $Identity"
$pw = & "$PSScriptRoot\\02-Reset-Password.ps1" -Identity $Identity -UserSearchBases $UserSearchBases
$attr = & "$PSScriptRoot\\03-Change-Attributes.ps1" -Identity $Identity -Domain $Domain -UserSearchBases $UserSearchBases
$grp = & "$PSScriptRoot\\04-Group-Noise.ps1" -Identity $Identity -UserSearchBases $UserSearchBases
$toggle = & "$PSScriptRoot\\05-Account-Toggle.ps1" -Identity $Identity -UserSearchBases $UserSearchBases
$upn = & "$PSScriptRoot\\06-UPN-Change.ps1" -Identity $Identity -Domain $Domain -UserSearchBases $UserSearchBases
$recon = & "$PSScriptRoot\\07-Recon-Noise.ps1" -Domain $Domain
$samr = & "$PSScriptRoot\\08-SAMR-Noise.ps1" -Domain $Domain
$net = & "$PSScriptRoot\\09-SMB-Noise.ps1" -Domain $Domain -SourceHost $env:COMPUTERNAME
Write-Host ($pw,$attr,$grp,$toggle,$upn,$recon,$samr,$net | ConvertTo-Json -Compress)
