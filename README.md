# ADLab
Powershell module used to faciliate the easy deployment of an Active Directory lab.

Heavily inspired by [xbufu's project](https://github.com/xbufu/ADLab). Wanted to try writing my own powershell module
and wanted to modify some implementation and extend some functionality of the aforementioned project.

# Navigation
Use the GitHub generated table of contents to browse the file easier. Located in the left upper hand corner of the
file as demo'd below

![](https://i.stack.imgur.com/Rxhkr.gif)

# Instructions

### Installation
You will need to move or copy the Module into the appropriate PSModulePath based on use case. Honestly I dont care
which path you put it in, but here are some examples

Install module for specific user. Might need to create this directory if it doesn't exist
```powershell
Move-Item .\ADLab\ $HOME\Documents\WindowsPowerShell\Modules
```

Install for all users via the Program Files directory
```powershell
Move-Item .\ADLab\ $Env:ProgramFiles\WindowsPowerShell\Modules
```

Install where windows installed modules go, i'd probably avoid this but i honestly dont care
```powershell
Move-Item .\ADLab\ $PSHome\Modules
```

### Import
After moving the module into the PSModulePath, you'll need to import the module before using any commands
```powershell
Import-Module ADLab
```

# Modules

## Deploy
Used for the deployment of domains, domain controllers, and services

### Deploy-LABDomain

### Deploy-LABDomainController

### Prepare-LABDomainController
Configures the hostname, static IP address, gateway, and hostname of the current host in preparation for the host to
be promoted to a Domain Controller

Prepare a new primary Domain Controller, for use when creating a new AD Forest
```powershell
Prepare-LABDomainCon.ps1 -Create -Hostname <String> -IPAddress <IPAddress> -Gateway <IPAddress> -DNSServer <IPAddress>
```

Prepare a Domain Controller to join an existing domain
```powershell
Prepare-LABDomainCon.ps1 -Join -Hostname <String> -IPAddress <IPAddress> -Gateway <IPAddress> -PrimaryDC <IPAddress> -DNSServer <IPAddress>
```

# To Do
- [ ] Revist the parameters in the Invoke-DCPrep.ps1

# Contributions
I don't claim this project as solely my own doing, I thank those listed below for either inspiration, ideas, or code.

Big thank you to [xbufu](https://github.com/xbufu), their [ADLab](https://github.com/xbufu/ADLab] project was a huge
inspiration (if you couldn't tell by the name). I struggle with structure of projects, so I followed the general
structure of their project and cobbled together some of my own scripts with some of their lines of code.