
Import-Module Sqlps;

$Server = "OFFSQLSTDD01";
$Database = "LTLTrack_Demo";
$inputScript = "C:\source\LTLTrack.demo\LTLTrack-Deployment\sql\TruncateLTLTables.sql";

New-PSDrive -Name "sqldrive" -ROOT SQLSERVER:\SQL\ -PSProvider "SqlServer" -WarningAction SilentlyContinue;

Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile $inputScript;
# Write-Output $result;


