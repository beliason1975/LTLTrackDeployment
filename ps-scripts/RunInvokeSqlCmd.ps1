
Function SQLInvoke {
    Param (
        [string]$server,
        [string]$database,
        [string]$inputFile
     )

    return Invoke-Sqlcmd -ServerInstance "$server" -Database "$database" -InputFile "$inputFile"
}

