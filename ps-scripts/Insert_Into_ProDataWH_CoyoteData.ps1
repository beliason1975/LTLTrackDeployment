param (
  [Parameter(Mandatory = $true)]
    [string]$server = "server",
    [Parameter(Mandatory = $true)]
    [string]$database = "database",
    [Parameter(Mandatory = $true)]
    [string]$inputFile = "inputFile",
    [Parameter(Mandatory = $true)]
    [string]$outServer = "outServer",
    [Parameter(Mandatory = $true)]
    [string]$outDatabase = "outDatabase",
    [Parameter(Mandatory = $true)]
    [string]$outTable = "outTable",
    [Parameter(Mandatory = $true)]
    [string]$schema = "schema"
)

$datatables = Invoke-Sqlcmd -ServerInstance "$server" -Database "$database" -InputFile "$inputFile" -QueryTimeout 65000 -OutputAs DataTable;

Write-SqlTableData -ServerInstance "$outServer" -Database "$outDatabase" -TableName "$outTable" -SchemaName "$schema" -Passthru -Timeout 999 -InputData $datatables;
