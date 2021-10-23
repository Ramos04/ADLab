Function Deploy-Workstation {
    <#
        .SYNOPSIS
        Preps the Windows Server for Domain Controller promotion

        .DESCRIPTION
        Configures the hostname, static IP address, gateway, and hostname of the current host in preparation for
        the host to be promoted to a Domain Controller

        .PARAMETER Secure
        Switch to allow the user to get prompted for credentials, rather than entering plaintext credentials

        .PARAMETER Domain
        Domain to join

        .PARAMETER Username
        Username of an administrator on the domain you're attempting to join

        .PARAMETER Password
        Password of an administrator on the domain you're attempting to join

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        None. Only writes logging info to the console.

        .EXAMPLE
        PS> Deploy-Workstation.ps1 -Secure -Domain test.domain -Username test.user

        .EXAMPLE
        PS> Deploy-Workstation.ps1 -Domain test.domain -Username test.user -Password sEcuR3PaSswoRd

        .LINK
        Online version: https://github.com/Ramos04/ADLab
    #>
    [CmdletBinding()]
    param(
        #[Parameter(Mandatory, ParameterSetName="SecureCredentials")]
        #[System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory, ParameterSetName="SecureCredentials")]
        [Switch]$Secure,

        [Parameter(Mandatory, ParameterSetName="InSecureCredentials")]
        [Parameter(Mandatory, ParameterSetName="SecureCredentials")]
        [ValidateNotNullOrEmpty()]
        [String]$Domain,

        [Parameter(Mandatory, ParameterSetName="InSecureCredentials")]
        [Parameter(Mandatory, ParameterSetName="SecureCredentials")]
        [ValidateNotNullOrEmpty()]
        [String]$Username,

        [Parameter(Mandatory, ParameterSetName="InSecureCredentials")]
        [ValidateNotNullOrEmpty()]
        [String]$Password
    )

    # Get the Operating System time
    $ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType

    # Create a credential object
    if ($Secure){
        $Credential = (Get-Credential -Credential "$Domain\$Username")
    } else{
        $DomainUser = "$Domain\$Username"
        $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $SecurePassword
    }

    # If the host is a workstation, join the domain
    if ($ProductType -eq 1){

        # Join the domain and reboot
        Write-Host "Attempting to join the domain, will reboot if successful.."
        Add-Computer -ComputerName $env:COMPUTERNAME -DomainName $Domain -Credential $Credential -Restart -Force
    }
}