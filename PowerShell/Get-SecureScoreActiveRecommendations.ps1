connect-mggraph SecurityEvents.Read.All

$ssresults = Get-MgBetaSecuritySecureScore -Top 1 | select -ExpandProperty ControlScores | select *
$ssprofiles = Get-MgBetaSecuritySecureScoreControlProfile | select * -unique | group id -AsHashTable -AsString
$possibleMaxScore = (Get-MgBetaSecuritySecureScore -Top 1).maxScore

foreach($ss in $ssresults){
    if($ssprofiles[$ss.controlName].Title){
        $ss | where {$ssprofiles[$ss.controlName].Title} | select  `
            @{N="Rank";E={"$($ssprofiles[$ss.controlName].rank)"}}, `
            @{N="Recommended action";E={"$($ssprofiles[$ss.controlName].Title)"}}, `
            @{N="implementationStatus";E={"$(($ss | select  -ExpandProperty AdditionalProperties | convertto-json -depth 99 | convertfrom-json).implementationStatus)"}}, `
            @{N="Score impact";E={"$("{0:P2}" -f ([int]$ssprofiles[$ss.controlName].maxscore / [int]$possibleMaxScore))"}}, `
            @{N="Points achieved";E={"$($ss.score) out of $($ssprofiles[$ss.controlName].maxscore)"}}, `
            @{N="Status";E={if($ss.score -ge $ssprofiles[$ss.controlName].maxscore){"Completed"}else{"To address"}}}, `
            @{N="Regress";E={"NA"}}, `
            @{N="Have license?";E={"NA"}}, `
            @{N="Category";E={"$($ss.ControlCategory)"}}, `
            @{N="Product";E={$ssprofiles[$ss.controlName].service}}, `
            @{N="Last synced";E={"$(($ss | select  -ExpandProperty AdditionalProperties | convertto-json -depth 99 | convertfrom-json).lastSynced)"}}, `
            @{N="ActionUrl";E={"$($ssprofiles[$ss.controlName].ActionUrl)"}}
    }
} where {$_.Status -ne "Completed"}
