
Function LoadModule {
    Param([string]$name)
    if (-not(Get-Module -name $name)) {
        if (Get-Module -ListAvailable |
                Where-Object { $_.name -eq $name }) {
            Import-Module -Name $name
            $true
        } 
        else { $false }
    }
    else { $true }
}
# LoadModule -name "smlets"
# # do precious things with smlets
# Remove-Module smlets 
