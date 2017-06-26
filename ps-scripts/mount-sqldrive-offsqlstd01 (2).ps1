# Import the SQL Server Module.  
Import-Module Sqlps -DisableNameChecking;
 
 $cred = Get-Credential;
New-PSDrive -Name "sqldrive" -Credential $cred -PSProvider SqlServer -ROOT SQLSERVER:\SQL\OFFSQLSTDD01\DEFAULT -WarningAction SilentlyContinue

Set-Location sqlserver:\SQL\OFFSQLSTDD01\default\databases




# # To check whether the module is installed. 
# Get-Module -ListAvailable -Name Sqlps;