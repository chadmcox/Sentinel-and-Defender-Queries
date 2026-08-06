param(
    [string]$HoneyToken = 'CN=honeypot,CN=Users,DC=contoso,DC=com',
    [string]$TestPassword = 'P@ssw0rd!123'
)

$ErrorActionPreference = 'Continue'

$target = Get-ADUser -Identity $HoneyToken -Properties SamAccountName, DistinguishedName, Description -ErrorAction SilentlyContinue
if (-not $target) {
    [pscustomobject]@{Activity='HoneypotNoiseSkipped';Identity=$HoneyToken;Reason='Not found';Timestamp=(Get-Date).ToString('o')}
    return
}

$stamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
Set-ADUser -Identity $target -Description "MDI lab honeypot check $stamp" -ErrorAction SilentlyContinue

[pscustomobject]@{
    Activity = 'HoneypotNoise'
    Identity = $target.SamAccountName
    DistinguishedName = $target.DistinguishedName
    Timestamp = (Get-Date).ToString('o')
}
