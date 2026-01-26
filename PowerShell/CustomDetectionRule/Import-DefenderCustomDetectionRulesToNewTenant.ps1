#Requires -Modules Microsoft.Graph.Beta.Security, Microsoft.Graph.Authentication
param($path="$env:USERPROFILE\downloads")

#the cmdlets work with version 2.24 powershell
#to install that version run
#find-module Microsoft.Graph.Beta.Security -RequiredVersion 2.24.0 | install-module
#find-module Microsoft.Graph.Authentication -RequiredVersion 2.24.0 | install-module

#or you can run it in newer powershell with latest release of modules
Disconnect-MgGraph
connect-mggraph -Scopes CustomDetection.Read.All,CustomDetection.ReadWrite.All

cd $path
dir -Path $path 'Defender CDR Export - *.json' | foreach{$cdr = $null
    $cdr = get-content $_.name | convertfrom-json | select DetectionAction, DisplayName, IsEnable, QueryCondition, Schedule,responseActions
    New-MgBetaSecurityRuleDetectionRule -BodyParameter ($cdr | convertto-json -Depth 99)
}
