param([Parameter(Mandatory)] [string]$TargetHost,[Parameter(Mandatory)] [string]$UserName,[Parameter(Mandatory)] [string]$Password)
$psExecPath = Join-Path $PSScriptRoot 'psexec.exe'
if (-not (Test-Path $psExecPath)) {
    [pscustomobject]@{Activity='PsExecSkipped';Reason='psexec.exe not found';Timestamp=(Get-Date).ToString('o')}; return
}
$cmd = "\\\$TargetHost -accepteula -u $UserName -p $Password cmd /c hostname"
& $psExecPath $cmd
[pscustomobject]@{Activity='PsExecNoise';TargetHost=$TargetHost;UserName=$UserName;Timestamp=(Get-Date).ToString('o')}
