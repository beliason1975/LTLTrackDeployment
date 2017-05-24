
# $plainPassword = "P!ppyg!rl01";
# $SecurePassword = $plainPassword | ConvertTo-SecureString -AsPlainText -Force
# $UserName = "PARADISE\\beliason";
# $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword

$CompName = "WEBAPPD01";
# $CompName = "R1CSGLP032A";

$process = get-wmiobject -query "SELECT * FROM Meta_Class WHERE __Class = 'Win32_Process'" -namespace "root\cimv2" -computername $CompName;

$results = $process.Create( 'start cmd.exe /c "C:\GetPositions\GetTruckPositions.exe"' );

write-host $results;
