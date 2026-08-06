param([string]$Domain)
$dc = (Get-ADDomainController).HostName
cmd /c "nslookup -type=SRV _ldap._tcp.$Domain $dc" | Out-Null
cmd /c "net view \\$dc" | Out-Null
[pscustomobject]@{Activity='ReconNoise';DC=$dc;Timestamp=(Get-Date).ToString('o')}
