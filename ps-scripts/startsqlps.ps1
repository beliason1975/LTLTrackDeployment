"C:\Program Files (x86)\Microsoft SQL Server\130\Tools\Binn\sqltoolsps.exe" -NoExit -Command "&{[System.Console]::Title = 'SQL Server Powershell';Convert-UrnToPath 'Server[@Name=''SPINQASQL01\INTERNET_QA'']/Database[@Name=''RoadrunnerCentral'']'|cd}"

import-module sqlps -DisableNameChecking
Import-Module sqlserver -DisableNameChecking -Force -PassThru
New-PSDrive -Name "sqldrive" -ROOT SQLSERVER:\SQL\ -PSProvider SqlServer;



SqlServer\Read-SqlTableData -ServerInstance OFFSQLSTDD01 -Database LTLTrack_Demo -InputFile "C:\\deployment\\sql\\RefreshProDataWH.sql"  | SQLSERVER\Write-SqlTableData -ServerInstance OFFSQLSTDD01 -Database LTLTRack_Demo -TableName ProDataWH -SchemaName dbo -Passthru;




