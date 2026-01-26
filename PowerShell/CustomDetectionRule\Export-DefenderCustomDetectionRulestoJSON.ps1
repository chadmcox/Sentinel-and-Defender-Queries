param($path="$env:USERPROFILE\downloads")

connect-mggraph -Scopes CustomDetection.Read.All,CustomDetection.ReadWrite.All

function getDefenderCustomRuleDetection{
    [cmdletbinding()] 
    param()
    $uri = "https://graph.microsoft.com/beta/security/rules/detectionRules"
    do{$results = $null
        for($i=0; $i -le 3; $i++){
            try{
                $results = Invoke-MgGraphRequest -Uri $uri -Method GET -OutputType PSObject
                break
            }catch{#if this fails it is going to try to authenticate again and rerun query
                if(($_.Exception.response.statuscode -eq "TooManyRequests") -or ($_.Exception.Response.StatusCode.value__ -eq 429)){
                    #if this hits up against to many request response throwing in the timer to wait the number of seconds recommended in the response.
                    write-host "Error: $($_.Exception.response.statuscode), trying again $i of 3"
                    Start-Sleep -Seconds $_.Exception.response.headers.RetryAfter.Delta.seconds
                }
            }
        }
        $results.value
        $uri=$null;$uri = $Results.'@odata.nextlink'
    }until ($uri -eq $null)
}


getDefenderCustomRuleDetection | foreach{
    $_ | convertto-json -Depth 99 | out-file -FilePath "$path\$($_.DisplayName).json"
}
