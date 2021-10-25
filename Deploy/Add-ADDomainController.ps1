Function Add-ADDomainController{
        <#
        .SYNOPSIS
        Adds a Domain Controller to an existing Active Directory Domain

        .DESCRIPTION
        Adds a Domain Controller to an existing Active Directory Domain

        .PARAMETER Username
        Username of the account to use when joining the domain

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        None. Only writes logging info to the console.

        .EXAMPLE
        PS> Add-ADDomainController -Domain domain.local -Username Administrator

        .LINK
        Online version: https://github.com/Ramos04/ADLab
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Domain,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Username
    )
    # Get the Operating System type
    $ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType

    if ($ProductType -eq 1){
        Write-Host "The host is not a Windows Server.." -Foreground Yellow
        Write-Host "Please use the Add-ADComputer module.." -Foreground Yellow
        Exit 1
    }
    else{
        Install-ADDSDomainController -InstallDns -DomainName $Domain -Credential (Get-Credential "$Domain\$Username") `
            -NoRebootOnCompletion:$false -Force:$true
    }
}