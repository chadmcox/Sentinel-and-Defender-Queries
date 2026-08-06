param([Parameter(Mandatory)] [string]$Identity,[string]$Domain,[string[]]$UserSearchBases = @('OU=Central,DC=contoso,DC=com','OU=User Accounts,DC=contoso,DC=com'))
function Get-UserInScope { param([string]$Name,[string[]]$Bases) foreach ($b in $Bases) { $u = Get-ADUser -Identity $Name -SearchBase $b -Properties SamAccountName,UserPrincipalName -ErrorAction SilentlyContinue; if ($u) { return $u } } Get-ADUser -Identity $Name -Properties SamAccountName,UserPrincipalName }
$target = Get-UserInScope -Name $Identity -Bases $UserSearchBases
$rand = Get-Random -Minimum 100 -Maximum 999
$newUpn = "labactivity$rand@$Domain"
Set-ADUser -Identity $target -UserPrincipalName $newUpn -ErrorAction Stop
Start-Sleep -Seconds 2
Set-ADUser -Identity $target -UserPrincipalName $target.UserPrincipalName -ErrorAction Stop
[pscustomobject]@{Activity='UPNChange';Identity=$target.SamAccountName;NewUPN=$newUpn;Timestamp=(Get-Date).ToString('o')}
