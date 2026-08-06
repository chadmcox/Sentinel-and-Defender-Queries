param([Parameter(Mandatory)] [string]$Identity,[string]$Domain,[string[]]$UserSearchBases = @('OU=Central,DC=contoso,DC=com','OU=User Accounts,DC=contoso,DC=com'))
function Get-UserInScope { param([string]$Name,[string[]]$Bases) foreach ($b in $Bases) { $u = Get-ADUser -Identity $Name -SearchBase $b -Properties SamAccountName -ErrorAction SilentlyContinue; if ($u) { return $u } } Get-ADUser -Identity $Name -Properties SamAccountName }
$target = Get-UserInScope -Name $Identity -Bases $UserSearchBases
$rand = Get-Random -Minimum 100 -Maximum 999
$manager = (Get-ADUser -Filter { SamAccountName -eq 'Administrator' } -SearchBase 'OU=Central,DC=contoso,DC=com').DistinguishedName
$upn = "mdi-lab-$rand@$Domain"
Set-ADUser -Identity $target -Title "Lab Activity $rand" -OfficePhone "+1-555-010-$rand" -EmailAddress $upn -Manager $manager -ErrorAction Stop
[pscustomobject]@{Activity='ChangeAttributes';Identity=$target.SamAccountName;EmailAddress=$upn;Phone="+1-555-010-$rand";Timestamp=(Get-Date).ToString('o')}
