connect-mggraph SecurityIdentitiesHealth.Read.All

get-MgBetaSecurityIdentityHealthIssue -filter "Status eq 'open'" | foreach{$hi = $_
    $hi | select Id -ExpandProperty AdditionalInformation | convertto-json -Depth 99 | convertfrom-json | foreach{
      $_ | select  @{N="Id";E={$hi.ID}}, `
        @{N="HealthIssue";E={$_}}
    }
}
