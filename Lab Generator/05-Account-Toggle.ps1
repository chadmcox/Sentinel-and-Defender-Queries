param([Parameter(Mandatory)] [string]$Identity,[string[]]$UserSearchBases = @('OU=Central,DC=contoso,DC=com','OU=User Accounts,DC=contoso,DC=com'))
function Get-UserInScope { param([string]$Name,[string[]]$Bases) foreach ($b in $Bases) { $u = Get-ADUser -Identity $Name -SearchBase $b -Properties SamAccountName,Enabled -ErrorAction SilentlyContinue; if ($u) { return $u } } Get-ADUser -Identity $Name -Properties SamAccountName,Enabled }
$target = Get-UserInScope -Name $Identity -Bases $UserSearchBases
$original = $target.Enabled
if ($original) { Disable-ADAccount -Identity $target -ErrorAction Stop; Start-Sleep -Seconds 2; Enable-ADAccount -Identity $target -ErrorAction Stop }
else { Enable-ADAccount -Identity $target -ErrorAction Stop; Start-Sleep -Seconds 2; Disable-ADAccount -Identity $target -ErrorAction Stop; Start-Sleep -Seconds 2; Enable-ADAccount -Identity $target -ErrorAction Stop }
[pscustomobject]@{Activity='ToggleAccountState';Identity=$target.SamAccountName;OriginalState=$original;Timestamp=(Get-Date).ToString('o')}
