# get-HBA-wwnn-from-iLO
  The script connects to the iLO and retrieves WWNN and MAC address of network adapters

## How to get Support
Simple scripts or tools posted on github are provided AS-IS and support is based on best effort provided by the author. If you encounter problems with the script, please submit an issue.

## Prerequisites
The script requires:
   * the latest HPERedFishCmdlets on PowerShell gallery
   * ImportExcel module from PowerShell gallery
  

## To install RedFish cmdlets and ImportExcel library modules

```
    install-Module HPERedFishcmdlets    -scope currentuser
    install-module ImportExcel          -scope CurrentUser
```

## To generate an Excel file with WWNN and MAC
```
    .\get-hba-wwnn.ps1 -iloIP <ilo_ip_address> -iloUser <ilo_username> -iLOpassword <ilo_password>
