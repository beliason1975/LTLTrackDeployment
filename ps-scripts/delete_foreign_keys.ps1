
$server = "OFFSQLSTDD01"
 
$tables = @("ProStatus", "ProTruckPosition", "ProReferenceLink")
$index_drop_script = "C:\Test\FKDrops.sql"
$index_create_script = "C:\Test\FKCreates.sql"
 
$database = Get-SqlDatabase -dbname "DatabaseName" -sqlserver $server
$tables = $database.Tables | where{$tables -contains $_.Name}
foreach($table in $tables)
{
    foreach($fk in $table.ForeignKeys)
    {
        #script create FK's
        $scriptingCreateOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
        $scriptingCreateOptions.IncludeDatabaseContext = $false
        $scriptingCreateOptions.IncludeHeaders = $false
        $scriptingCreateOptions.IncludeIfNotExists = $true
        $scriptingCreateOptions.DriForeignKeys = $true
        $fk.Script($scriptingCreateOptions) -join "`nGO`n`n" | Out-File -FilePath $index_create_script -Append
         
        #script drop FK's
        $scriptingDropOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
        $scriptingDropOptions.IncludeIfNotExists = $true
        $scriptingDropOptions.IncludeHeaders = $false
        $scriptingDropOptions.ScriptDrops = $true
        $fk.Script($scriptingDropOptions) -join "`nGO`n`n" | Out-File -FilePath $index_drop_script -Append
         
    }
}
