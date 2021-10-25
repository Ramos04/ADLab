Function Add-ADComputer {
    <#
        .SYNOPSIS
        Add's a computer to an Active Directory domain

        .DESCRIPTION
        Add's a computer to an Active Directory domain

        .PARAMETER Domain
        Domain to join

        .PARAMETER Username
        Username of the credentials to use to join the domain with

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        None. Only writes logging info to the console.

        .EXAMPLE
        PS> Add-ADComputer -Domain domain.local -Username Administrator

        .LINK
        Online version: https://github.com/Ramos04/ADLab
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$Domain,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Username
    )
    # Get the Operating System type
    $ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType

    # If the host is a workstation, join the domain
    if ($ProductType -eq 1){
        Write-Host "Attempting to join the domain, will reboot if successful.."
        Add-Computer -ComputerName $env:COMPUTERNAME -DomainName $Domain `
            -Credential (Get-Credential "$Domain\$Username") -Restart -Force
    }
    else{
        Write-Host "Host is not a workstation.." -Foreground Yellow
        Write-Host "Please use the Add-ADDomainController module.." -Foreground Yellow
        Exit 1
    }






















    # Create the credentials or prompt user, based on parameter set used
    if ($PSCmdlet.ParameterSetName -eq "SecureCredentials"){
        $Credential = (Get-Credential -Credential "$Domain\$Username")
    } else{
        $DomainUser = "$Domain\$Username"
        $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $SecurePassword
    }

    # If the host is a workstation, join the domain
    if ($ProductType -eq 1){
        Write-Host "Attempting to join the domain, will reboot if successful.."
        Add-Computer -ComputerName $env:COMPUTERNAME -DomainName $Domain -Credential $Credential -Restart -Force
    }
    else{
        Write-Host "Host is not a workstation.." -Foreground Yellow
        Write-Host "Please use the Add-ADDomainController module.." -Foreground Yellow
        Exit 1
    }
}