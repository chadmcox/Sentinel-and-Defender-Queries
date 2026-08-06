param([string]$Domain)
cmd /c "net user /domain" | Out-Null
cmd /c "net group /domain" | Out-Null
cmd /c "net group \"Domain Admins\" /domain" | Out-Null
cmd /c "net group \"Enterprise Admins\" /domain" | Out-Null
[pscustomobject]@{Activity='SAMRNoise';Timestamp=(Get-Date).ToString('o')}
