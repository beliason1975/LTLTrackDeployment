param (
  [Parameter(Mandatory = $true)]
    [string]$server = "server",
    [Parameter(Mandatory = $true)]
    [string]$database = "database",
    [Parameter(Mandatory = $true)]
    [string]$inputFile = "inputFile"
)

Invoke-Sqlcmd -ServerInstance "$server" -Database "$database" -InputFile "$inputFile" -QueryTimeout 65000;

