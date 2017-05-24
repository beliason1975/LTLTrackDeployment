$serviceName = "UpdateProPositions"

# verify if the service already exists, and if yes remove it first
if (Get-Service $serviceName -ErrorAction SilentlyContinue)
{
	# using WMI to remove Windows service because PowerShell does not have CmdLet for this
    $serviceToRemove = Get-WmiObject -Class Win32_Service -Filter "name='$serviceName'"
    $serviceToRemove.delete()
    "service removed"
} 
else
{
	# just do nothing
    "service does not exists"
}

"installing service"
# creating credentials which can be used to run my windows service
$cred = Get-Credential

# $secpasswd = ConvertTo-SecureString "MyPa$$word" -AsPlainText -Force
# $mycreds = New-Object System.Management.Automation.PSCredential (".\MyUserName", $secpasswd)

$binaryPath = ".\UpdateProPositions.exe"

# creating widnows service using all provided parameters
New-Service -name $serviceName -binaryPathName $binaryPath -displayName $serviceName -startupType Automatic -credential $cred

"installation completed"