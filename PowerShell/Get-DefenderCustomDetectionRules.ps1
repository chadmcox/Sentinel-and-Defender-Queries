connect-mggraph SecurityIdentitiesHealth.Read.All,SecurityIdentitiesSensors.Read.All,SecurityIdentitiesAccount.Read.All,SecurityEvents.Read.All,CustomDetection.ReadWrite.All,CustomDetection.Read.All,Application.Read.All,Application.ReadWrite.All,`
AuditLog.Read.All,CrossTenantInformation.ReadBasic.All,Directory.AccessAsUser.All,Directory.Read.All,Directory.ReadWrite.All,Group.Read.All,OnPremDirectorySynchronization.ReadWrite.All,openid,Policy.Read.All,`
PrivilegedAccess.Read.AzureAD,PrivilegedAccess.Read.AzureADGroup,PrivilegedAccess.Read.AzureResources,profile,RoleManagement.Read.All,RoleManagement.ReadWrite.Directory,SecurityEvents.Read.All,`
SecurityIdentitiesAccount.Read.All,SecurityIdentitiesHealth.Read.All,SecurityIdentitiesSensors.Read.All,User.Read,User.Read.All,User.ReadBasic.All,UserAuthenticationMethod.Read.All,email

#https://learn.microsoft.com/en-us/graph/api/security-detectionrule-list?view=graph-rest-beta&tabs=http

Get-MgBetaSecurityRuleDetectionRule | select *
