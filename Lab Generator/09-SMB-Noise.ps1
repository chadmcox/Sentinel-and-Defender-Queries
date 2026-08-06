param([string]$Domain,[string]$SourceHost)
$dc = (Get-ADDomainController).HostName
cmd /c "net use \\\\$dc\\IPC$ /user:$Domain\\$SourceHost" | Out-Null
cmd /c "net view \\\\$dc" | Out-Null
[pscustomobject]@{Activity='SMBNoise';DC=$dc;SourceHost=$SourceHost;Timestamp=(Get-Date).ToString('o')}
