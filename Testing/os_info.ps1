#Requires -RunAsAdministrator

# https://stackoverflow.com/questions/48592120/how-do-i-find-out-from-powershell-if-i-am-on-a-server-or-workstation

# ProductType
#   Work Station (1)
#   Domain Controller (2)
#   Server (3)
$productType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType