Function New-ADForest {
    <#
        .SYNOPSIS
        Create a new Active Directory forest

        .DESCRIPTION
        Creates a new Active Directory forest, promotes the windows server to a
        Domain Controller, and creates a new domain

        .PARAMETER Domain
        Domain to create

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        None. Only writes logging info to the console.

        .EXAMPLE
        PS> New-ADForest -Domain domain.local

        .LINK
        Online version: https://github.com/Ramos04/ADLab
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Domain
    )

    if ($ProductType -eq 1){
        Write-Host "The host is not a Windows Server.." -Foreground Yellow
        Write-Host "Please user the Add-ADComputer module.." -Foreground Yellow
        exit 1
    }
    else{
        # Set the NetBIOS name variable
        $NetBIOSName = ($Domain.Split(".")[0]).ToUpper()

        # Check if AD-Domain-Services is installed, if not install it
        if (-Not (Get-WindowsFeature AD-Domain-Services).Installed){
            Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        }

        # Import ADDS module
        Import-Module ADDSDeployment

        # Create the new forest
        Install-ADDSForest -InstallDNS -DomainName $Domain -DomainNetbiosName $ $NetBIOSName -DomainMode WinThreshold `
            -ForestMode WinThreshold -CreateDnsDelegation:$false -NoRebootOnCompletion:$false -Force:$true
    }
}