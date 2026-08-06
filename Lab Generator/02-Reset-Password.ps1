param([Parameter(Mandatory)] [string]$Identity,[string[]]$UserSearchBases = @('OU=Central,DC=contoso,DC=com','OU=User Accounts,DC=contoso,DC=com'))
$ErrorActionPreference = 'Stop'
$protected = @('Administrator','chad')
if ($protected -contains $Identity) { [pscustomobject]@{Activity='ResetPasswordSkipped';Identity=$Identity;Reason='Protected account';Timestamp=(Get-Date).ToString('o')} ; return }
function Get-UserInScope { param([string]$Name,[string[]]$Bases) foreach ($b in $Bases) { $u = Get-ADUser -Identity $Name -SearchBase $b -Properties SamAccountName -ErrorAction SilentlyContinue; if ($u) { return $u } } Get-ADUser -Identity $Name -Properties SamAccountName }
$target = Get-UserInScope -Name $Identity -Bases $UserSearchBases
$pwd = "P@ssw0rd!" + (Get-Random -Minimum 100 -Maximum 999)
$secure = ConvertTo-SecureString $pwd -AsPlainText -Force
Set-ADAccountPassword -Identity $target -Reset -NewPassword $secure -PassThru | Out-Null
[pscustomobject]@{Activity='ResetPassword';Identity=$target.SamAccountName;Password=$pwd;Timestamp=(Get-Date).ToString('o')}
