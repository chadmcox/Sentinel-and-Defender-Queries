param($defaultpath="$env:USERPROFILE\downloads")

#https://learn.microsoft.com/en-us/graph/api/security-detectionrule-list?view=graph-rest-beta&tabs=http
connect-mggraph -scope CustomDetection.Read.All

Get-MgBetaSecurityRuleDetectionRule -all | foreach{
    $_ | convertto-json -Depth 99 | out-file -FilePath "c:\data\Detectionbackup\$($_.DisplayName).json"
}
