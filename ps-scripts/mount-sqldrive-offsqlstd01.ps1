# Import the SQL Server Module.
Import-Module Sqlps -DisableNameChecking;

$PlainPassword = "Password1";
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force;
$UserName = "SQLAccess";
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword;
# $SecureStringAsPlainText = $SecurePassword | ConvertFrom-SecureString

New-PSDrive -Name SQLSERVER -ROOT 'SQLSERVER:\SQL\[SPINSQLC01\INTERNET]' -PSProvider SqlServer -Credential $Credentials -WarningAction SilentlyContinue

# Set-Location sqlserver:\SQL\OFFSQLSTDD01\default\databases # # To check whether the module is installed. # Get-Module -ListAvailable -Name Sqlps;
