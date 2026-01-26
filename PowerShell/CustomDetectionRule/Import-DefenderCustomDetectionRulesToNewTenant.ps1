param($path="$env:USERPROFILE\downloads")

Disconnect-MgGraph
connect-mggraph -Scopes CustomDetection.Read.All,CustomDetection.ReadWrite.All

cd $path
dir -Path $path 'Defender CDR Export - *.json' | foreach{$cdr = $null
    $cdr = get-content $_.name | convertfrom-json | select DetectionAction, DisplayName, IsEnable, QueryCondition, Schedule,responseActions
    New-MgBetaSecurityRuleDetectionRule -BodyParameter ($cdr | convertto-json -Depth 99)
}
