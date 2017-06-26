

Write-Host "Truncating table:<ProDataWH> in database:<LTLTrack>";
Invoke-Sqlcmd -ServerInstance "OFFSQLSTDD01" -Database "LTLTrack" -Query "truncate table ProDataWH";
Write-Host "Truncating table:<ProDataWH> completed successfully";

Write-Host "Getting data from:<CoyoteDataWarehouse>";
$datatables = Invoke-Sqlcmd -ServerInstance "OFFSQLENTD01" -Database "CoyoteDataWarehouse" -InputFile '.\sql\RefreshProDataWH.sql' -QueryTimeout 65000 -OutputAs DataTable;
Write-Host "Done getting data from:<CoyoteDataWarehouse>. Inserting data to:<LTLTrack.ProDataWH>";
Write-SqlTableData -ServerInstance "OFFSQLSTDD01" -Database "LTLTrack" -TableName "ProDataWH" -SchemaName "dbo" -Passthru -Timeout 999 -InputData $datatables;
Write-Host "Inserting to:<ProDataWH> completed successfully.";

Write-Host "Inserting new Pro records";
Invoke-Sqlcmd -ServerInstance "OFFSQLSTDD01" -Database "LTLTrack" -InputFile '.\sql\InsertNewPros.sql';
Write-Host "Inserting new ProTruck records";
Invoke-Sqlcmd -ServerInstance "OFFSQLSTDD01" -Database "LTLTrack" -InputFile '.\sql\InsertNewProTrucks.sql';
Write-Host "Updating any removed pros to not be updated with position data";
Invoke-Sqlcmd -ServerInstance "OFFSQLSTDD01" -Database "LTLTrack" -InputFile '.\sql\SetFlagNonActiveProTrucks.sql';
Write-Host "Process completed successfully";




