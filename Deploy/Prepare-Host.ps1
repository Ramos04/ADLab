Function Deploy-LABDomainController {
    <#
        .SYNOPSIS
        Preps the Windows Server for Domain Controller promotion

        .DESCRIPTION
        Configures the hostname, static IP address, gateway, and hostname of the current host in preparation for
        the host to be promoted to a Domain Controller

        .PARAMETER Create
        Preps the server to be the primary Domain Controller of the forest

        .PARAMETER Join
        Preps the server to join an Active Directory foreset.

        .PARAMETER Hostname
        New hostname of the server.

        .PARAMETER IPAddress
        New IP Address of the server.

        .PARAMETER Gateway
        New gateway of the server.

        .PARAMETER DomainController
        IP Address of the primary Domain Controller in the forest.

        .PARAMETER DNSServer
        IP Address of the secondary DNS server to user. Note, will set the first DNS server to either 127.0.0.1 or the
        IP ADress of the primary Domain Controller based on the Create or Join parameter. Do not use the IP Address of
        this server for this parameter.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        None. Only writes logging info to the console.

        .EXAMPLE
        PS> Prepare-LABDomainController.ps1 -Create [-Hostname <string>] [-IPAddress <ipaddress>] [-Gateway <ipaddress>] [-DNSServerTwo <ipaddress>]

        .EXAMPLE
        PS> Prepare-LABDomainController.ps1 -Join -DomainController <ipaddress> [-Hostname <string>] [-IPAddress <ipaddress>] [-Gateway <ipaddress>] [-DNSServer <ipaddress>]

        .LINK
        Online version: https://github.com/Ramos04/ADLab
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName="Create", HelpMessage="Create a new domain")]
        [Switch]$Create,

        [Parameter(Mandatory, ParameterSetName="Join", HelpMessage="Join server to an existing domain")]
        [Switch]$Join,

        [Parameter(ParameterSetName="Create", HelpMessage="New Hostname")]
        [Parameter(ParameterSetName="Join", HelpMessage="New Hostname")]
        [ValidateLength(1, 63)]
        [ValidatePattern('^[a-z0-9-]+$')]
        [ValidateNotNullOrEmpty()]
        [String]$Hostname = $env:COMPUTERNAME,

        [Parameter(ParameterSetName="Create", HelpMessage="New static IPv4 address")]
        [Parameter(ParameterSetName="Join", HelpMessage="New static IPv4 address")]
        [ValidateNotNullOrEmpty()]
        [IPAddress]$IPAddress =
            ((Get-NetIpAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -AddressFamily "IPv4").IPAddress),

        [Parameter(ParameterSetName="Create", HelpMessage="New static IPv4 gateway")]
        [Parameter(ParameterSetName="Join", HelpMessage="New static IPv4 gateway")]
        [ValidateNotNullOrEmpty()]
        [IPAddress]$Gateway =
            ((Get-NetIPConfiguration -InterfaceIndex (Get-NetAdapter).InterfaceIndex).IPv4DefaultGateway.NextHop),

        [Parameter(Mandatory, ParameterSetName="Join", HelpMessage="IPv4 address of primary Domain Controller")]
        [ValidateNotNullOrEmpty()]
        [IPAddress]$DomainController,

        [Parameter(ParameterSetName="Create", HelpMessage="IPv4 address of second DNS server")]
        [Parameter(ParameterSetName="Join", HelpMessage="IPv4 address of second DNS server")]
        [ValidateNotNullOrEmpty()]
        #[Alias("DNSServer")]
        [IPAddress]$DNSServer =
            ((Get-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex `
                -AddressFamily "IPv4").ServerAddresses | Select-Object -last 1)
    )

    # Set the DNSServerTwo
    $DNSServerTwo = $DNSServer

    # Check if verbose
    $VerboseFlag = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)

    # Get product type
    $ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType

    # Get the network interface index
    $InterfaceIndex = (Get-NetAdapter).InterfaceIndex

    # Set the DNS hosts based off the -Create or -Join
    if ($Create){
        # If the user is trying to create a domain on a workstation, kill the script
        if ($ProductType -eq 1){
            Write-Host "Cannot create a new domain on a workstation..." -Foreground Red
            [Environment]::Exit(1)
        }

        $DNSServerOne = "127.0.0.1"
    }
    elseif ($Join) {
        $DNSServerOne = $DomainController
    }

    if ($VerboseFlag){
        Write-Host "+---------------------------------+"
        Write-Host "|            Variables            |"
        Write-Host "+---------------------------------+"
        "{0,-18}: {1}" -f "HOSTNAME", $Hostname
        "{0,-18}: {1}" -f "IP ADDRESS", "$IPAddress"
        "{0,-18}: {1}" -f "GATEWAY", "$Gateway"
        "{0,-18}: {1}" -f "DNS SERVER ONE", "$DNSServerOne"
        "{0,-18}: {1}" -f "DNS SERVER TWO", "$DNSServerTwo"
        "{0,-18}: {1}" -f "DOMAIN CONTROLLER", "$DomainController"
        Write-Host
    }

    # Clear the previous IPv4 and IPv6 addresses
    Write-Host "Removing the previous IPv4 and IPv6 addresses.."
    Remove-NetIPAddress -AddressFamily "IPv4" -InterfaceIndex $InterfaceIndex -Confirm:$false
    Remove-NetIPAddress -AddressFamily "IPv6" -InterfaceIndex $InterfaceIndex -Confirm:$false

    # Set the new IP Address
    Write-Host "Setting the new IP address to $IPAddress.."
    New-NetIpAddress -InterfaceIndex $InterfaceIndex -AddressFamily "IPv4" -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $Gateway | Out-Null

    # Set the new DNS Servers
    Write-Host "Setting new DNS servers to $DNSServerOne and $DNSServerTwo..."
    Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses ($DNSServerOne, $DNSServerTwo)

    # Disable IPv6 if joining a domain, idk why but it fucks up DC resolution
    if ($Join){
        Write-Host "Disabling IPv6 on all ethernet adapters"
        Get-NetAdapter | foreach { Disable-NetAdapterBinding -InterfaceAlias $_.Name -ComponentID ms_tcpip6 }
    }

    # Change the hostname
    Write-Host "Changing the host name to $Hostname, will reboot automatically.."
    Rename-Computer -NewName $Hostname -Restart -Force
}