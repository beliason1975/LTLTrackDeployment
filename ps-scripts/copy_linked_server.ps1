# Copy-SqlLinkedServer -Source sqlserver2014a -SourceSqlCredential sqladmin -Destination sqlcluster -LinkedServers mySQL1, lssvr1 -Force
# Copy-SqlLinkedServer -Source 'SPINSQLC01\INTERNET' -SourceSqlCredential sqladmin  -Destination OFFSQLSTDD01 -LinkedServers MCLEOD -WhatIf

# Copy-SqlLinkedServer -Source SPINSQLC01\INTERNET -Destination OFFSQLSTDD01 -WhatIf


$PlainPassword = "Password1";
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force;
$UserName = "svc_linkedserver";
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword;


# Export-SqlLogin -SqlServer SPINSQLC01\INTERNET -SqlCredential $Credentials -FilePath C:\temp\sql2005-logins.sql
Copy-SqlLinkedServer -Source 'SPINSQLC01\INTERNET' -SourceSqlCredential $Credentials  -Destination OFFSQLSTDD01  -WhatIf
