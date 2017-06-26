Clear-Host;

# Import the SQL Server Module.
Import-Module Sqlps;

# Check to see if sqlps is already opened


# $PlainPassword = "P!ppyg!rl01";
# $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force;

# $UserName = "PARADISE\beliason";
# $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword;
# # $SecureStringAsPlainText = $SecurePassword | ConvertFrom-SecureString

$Server = "OFFSQLENTD01";
$Database = "CoyoteDataWarehouse";
$RefreshScript = "c:\source\ltltrack.demo\LTLTrack-Deployment\sql\RefreshProDataWH.sql";

# Set-SqlAuthenticationMode -Mode Integrated -SqlCredential $Credentials

New-PSDrive -Name "sqldrive" -ROOT SQLSERVER:\SQL\ -PSProvider "SqlServer" -WarningAction SilentlyContinue;

# $database = Get-SqlDatabase -Name $Database -ServerInstance $server

# $str = Get-Content -Path "C:\Users\beliason.PARADISE\OneDrive - Bearclaw Technologies\RRTS\LTLTrack-GetActiveProswc\trunk\sql\RefreshProDataWH.sql";
# $file = ".\RefreshProDataWH.sql";
# $query = $str -split [System.Environment]::NewLine;
# Set-SqlAuthenticationMode -Credential $Credentials -Mode Integrated;
# $datarows = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile $RefreshScript -OutputAs datarows;

$datatables = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile $RefreshScript -OutputAs DataTables;
# Invoke-Sqlcmd -ServerInstance $Server -Database $Database -InputFile $RefreshScript;
# Write-Output -InputObject datarows  $datatable
# Write-Output $datarows;

#Get column names
$colNames = $datatables |
        ForEach-Object {$_.Columns} |
            Select-Object Name, DataType,
                @{Name='Length'; Expression = {$_.Properties['Length'].Value}}
$colNames


# $dataTable = $datatables[0];
# foreach ($col in $dataTable.Columns) {
#     Write-Host "column: " + $col.ColumnName;
# }

# for($i=1; $i -lt $dataTable.Rows.length; $i++){
#     Write-Host "data row: " +  $datarows[$i];
#     #  $datarows[$i]["Manifest"]
#      $datarows[$i]
# }



# # Do it
# $dt = New-Object System.Data.Datatable;

# $col = new-object System.Data.co;
# $reader = New-Object System.IO.StreamReader $csvfile;
# $columns = (Get-Content $csvfile -First 1).Split($csvdelimiter)

# foreach ($column in $columns) {
#  if ($firstRowColumns -eq $true) {
#  [void]$dt.Columns.Add($column)
#  $reader.ReadLine()
#  } else { [void]$dt.Columns.Add() }
# }

# # Read in the data, line by line
# while (($line = $reader.ReadLine()) -ne $null)  {
#  [void]$dt.Rows.Add($line.Split($csvdelimiter))
# }











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

