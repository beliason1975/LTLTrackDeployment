$SERVER_OFFSQLENTD01 = "OFFSQLENTD01";
$SERVER_OFFSQLSTDD01 = "OFFSQLSTDD01";
$DATABASE_COYOTE = "CoyoteDataWarehouse";
$DATABASE_LTLTRACK = "LTLTrack";
$TABLE_PRODATAWH = "ProDataWH";

$server = "OFFSQLSTDD01";
$database = "LTLTrack";
$table = "ProDataWH";
$schema = "dbo";
$coyote_server = "OFFSQLENTD01";
$coyote_database = "CoyoteDataWarehouse";
Write-Host "Truncating table:<$table> in database:<$database>";
Invoke-Sqlcmd -ServerInstance "$server" -Database "$database" -Query "truncate table ProDataWH";
Write-Host "Truncating table:<$table> completed successfully";

Write-Host "Getting data from:<$coyote_database>";
$datatables = Invoke-Sqlcmd -ServerInstance "$coyote_server" -Database "$coyote_database" -InputFile '.\\sql\\RefreshProDataWH.sql' -QueryTimeout 65000 -OutputAs DataTable;
Write-Host "Done getting data from:<$coyote_database>. Inserting data to:<$database>";
Write-SqlTableData -ServerInstance "$server" -Database "$database" -TableName "$table" -SchemaName "$schema" -Passthru -Timeout 999 -InputData $datatables;
Write-Host "Inserting to:<$database> completed successfully.";

Invoke-Sqlcmd -ServerInstance "$server" -Database "$database" -InputFile '.\\sql\\InsertNewPros.sql';
Invoke-Sqlcmd -ServerInstance "$server" -Database "$database" -InputFile '.\\sql\\InsertNewProTrucks.sql';
Invoke-Sqlcmd -ServerInstance "$server" -Database "$database" -InputFile '.\\sql\\SetFlagNonActiveProTrucks.sql';


