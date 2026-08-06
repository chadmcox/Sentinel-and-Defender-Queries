param(
    [Parameter(Mandatory)] [string]$Identity,
    [Parameter(Mandatory)] [string]$Password,
    [string]$Domain = 'contoso.com'
)

$ErrorActionPreference = 'Continue'

$success = $false
$reason = ''
try {
    $entry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Domain", $Identity, $Password)
    $null = $entry.Properties['distinguishedName'].Value
    $success = $true
} catch {
    $reason = $_.Exception.Message
}

[pscustomobject]@{
    Activity = 'SimpleBindTest'
    Identity = $Identity
    Domain = $Domain
    Success = $success
    Reason = $reason
    Timestamp = (Get-Date).ToString('o')
}
