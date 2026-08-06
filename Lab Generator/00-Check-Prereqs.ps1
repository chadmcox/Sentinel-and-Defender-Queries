param([string]$Domain = (Get-ADDomain).DNSRoot)

$ErrorActionPreference = 'Stop'

Write-Host "Domain: $Domain"
Write-Host "Source host: $env:COMPUTERNAME"

if (-not (Get-Module -ListAvailable ActiveDirectory)) {
    throw 'ActiveDirectory module not available'
}

$dc = (Get-ADDomainController).HostName
Write-Host "Domain controller: $dc"

Get-ADUser -Filter * -SearchBase 'OU=Central,DC=contoso,DC=com' -Properties SamAccountName | Out-Null
Write-Host 'AD lookup succeeded in OU=Central,DC=contoso,DC=com'

$psExecPath = Join-Path $PSScriptRoot 'psexec.exe'
if (Test-Path $psExecPath) {
    Write-Host 'PsExec binary found in script folder'
} else {
    Write-Host 'PsExec binary not found in script folder - PsExec-style remote execution will be skipped'
}
