

    $datatables = Invoke-Sqlcmd -ServerInstance "OFFSQLENTD01" -Database "CoyoteDataWarehouse" -InputFile "c:\\deployment\\sql\\RefreshProDataWH.sql"  -OutputSqlErrors $true;
    Write-SqlTableData -ServerInstance "OFFSQLSTDD01" -Database "LTLTRack_Demo" -TableName "ProDataWH" -SchemaName "dbo" -Passthru -InputData $datatables;

