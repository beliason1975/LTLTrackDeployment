







$Server = "OFFSQLSTDD01";
$Database = "LTLTrack_Demo";
$tableName = "ProDataWH";


# $db = Get-SqlDatabase -Name $Database -ServerInstance $Server
# $MyVar = New-Object Microsoft.SqlServer.Management.SMO.Database
#         $MyVar | Get-Member -Type Methods
#         $MyVar | Get-Member -Type Properties

try {
    write-host "Writing data to Server"
    Write-SqlTableData -ServerInstance $Server -Database $Database -TableName $tableName -SchemaName "dbo" -Passthru -InputData $datatables
    # $sinceDate = Get-Date -Since Yesterday;
    # $sqlErrorLog = Get-SqlErrorLog  -ServerInstance $Server -After $sinceDate;

    Write-host "Data written"


    # Write-Host "Sql log bitch"
}
catch [Exception] {
    write-host $_.Exception.ToString()
    write-host $_.Exception.Data
}

