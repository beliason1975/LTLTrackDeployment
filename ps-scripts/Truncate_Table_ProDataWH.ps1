param (
    [Parameter(Mandatory = $true)]
    [string]$server = "server",
    [Parameter(Mandatory = $true)]
    [string]$database = "database"
)
# $server
# $database
Write-Host "truncating table ProDataWH in database <$database>";
Invoke-Sqlcmd -ServerInstance "$server" -Database "$database" -Query "truncate table ProDataWH";

