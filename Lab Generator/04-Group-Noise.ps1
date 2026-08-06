param(
    [Parameter(Mandatory)] [string]$Identity,
    [string[]]$UserSearchBases = @('OU=Central,DC=contoso,DC=com','OU=User Accounts,DC=contoso,DC=com'),
    [string[]]$GroupSearchBases = @(
        'OU=Groups,DC=contoso,DC=com',
        'OU=Security Groups,OU=Groups,DC=contoso,DC=com',
        'OU=Distribution Groups,OU=Groups,DC=contoso,DC=com',
        'OU=CloudGroups,DC=contoso,DC=com',
        'OU=Groups,OU=Toronto,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Moscow,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=London,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Phoenix,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Seattle,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Redmond,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=San Francisco,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=New York,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Dallas,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Denver,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Charolette,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Minneapolis,OU=Central,DC=contoso,DC=com',
        'OU=Groups,OU=Tier 0,OU=Admin,DC=contoso,DC=com',
        'OU=Groups,OU=Tier 1,OU=Admin,DC=contoso,DC=com',
        'OU=Groups,OU=Tier 2,OU=Admin,DC=contoso,DC=com'
    )
)

function Get-UserInScope { param([string]$Name,[string[]]$Bases) foreach ($b in $Bases) { $u = Get-ADUser -Identity $Name -SearchBase $b -Properties SamAccountName -ErrorAction SilentlyContinue; if ($u) { return $u } } Get-ADUser -Identity $Name -Properties SamAccountName }
function Get-TargetGroups {
    param([string[]]$Bases)
    $groups = foreach ($base in $Bases) {
        Get-ADGroup -Filter * -SearchBase $base -Properties Name, DistinguishedName | Where-Object {
            $_.Name -notmatch 'Domain Users|Remote Desktop Users|Guests|Administrator|Schema Admins|Enterprise Admins|Domain Admins'
        }
    }
    return $groups | Sort-Object { Get-Random } | Select-Object -First 3
}

$target = Get-UserInScope -Name $Identity -Bases $UserSearchBases
$targetGroups = Get-TargetGroups -Bases $GroupSearchBases
foreach ($group in $targetGroups) {
    try { Add-ADGroupMember -Identity $group -Members $target -ErrorAction Stop; Remove-ADGroupMember -Identity $group -Members $target -Confirm:$false -ErrorAction Stop }
    catch { Write-Warning "Group noise skipped for $($group.DistinguishedName) : $($_.Exception.Message)" }
}
[pscustomobject]@{Activity='GroupMembershipNoise';Identity=$target.SamAccountName;GroupCount=@($targetGroups).Count;Timestamp=(Get-Date).ToString('o')}
