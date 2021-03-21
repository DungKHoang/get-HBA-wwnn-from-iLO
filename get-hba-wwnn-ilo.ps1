# ------------------ Parameters
Param (                    
        [string]$iLOip                    = "", 
        [string]$iLOuser                  = "", 
        [string]$iLOpassword              = ""
)

class networkAdapter
{
    [string]$name
    [string]$serialNumber
    [string]$port
    [string]$mac
    [string]$wwnn
}

function writeto-Excel($data, $sheetName, $destWorkbook)
{
    if ($destWorkBook -and $data)
    {
            
        $data | Export-Excel -path $destWorkBook  -WorksheetName $sheetName
    }
}


# --------------------------
# Main Entry
# --------------------------
$sheetName          = "Adapter WWNN MAC"
$destWorkBook       = "Adapter-WWNN-MAC.xlsx"


if ($iLOip -or $iLOuser -or $iLOpassword)
{
    $iloSession         = Connect-HPERedfish -Address $iLOip -Username $iLOuser -Password $iLOpassword -DisableCertificateAuthentication
    if ($iloSession)
    {
        $valuesArray    = New-Object System.Collections.ArrayList
        $sys            = Get-HPERedfishDataRaw -session $iloSession -DisableCertificateAuthentication  -odataid '/redfish/v1/Systems'
        foreach ($odata in $sys.members.'@odata.id' )
        {
            $odata      = $odata + '/basenetworkadapters'
            $baseNet    = Get-HPERedfishDataRaw -session $iloSession -DisableCertificateAuthentication  -odataid $odata
            foreach ($odataNet in $baseNet.members.'@odata.id' )
            {
                $nic    = Get-HPERedfishDataRaw -session $iloSession -DisableCertificateAuthentication  -odataid $odataNet
                if ($nic)
                {
                    $macArray               = New-Object System.Collections.ArrayList
                    $wwnnArray              = New-Object System.Collections.ArrayList
                    $portArray              = New-Object System.Collections.ArrayList
                    $adapter                = New-Object -TypeName networkAdapter

                    $adapter.name           = $nic.name
                    $adapter.serialNumber   = $nic.SerialNumber


                    foreach ($p in $nic.fcPorts)
                    {
                        [void]$portArray.Add($p.PortNumber)
                        [void]$wwnnArray.Add($p.wwnn)
                    }
                    
                    foreach ($p in $nic.PhysicalPorts)
                    {
                        [void]$macArray.Add($p.MacAddress)
                    }

                    $adapter.port       = if ($portArray) { $portArray -join '|' } else {''}
                    $adapter.wwnn       = if ($wwnnArray) { $wwnnArray -join '|' } else {''}
                    $adapter.mac        = if ($macArray)  { $macArray  -join '|' } else {''}

                    [void]$valuesArray.Add($adapter)


                }

            }
        }

        if ($ValuesArray)
        {
            write-host -foreground Cyan " Generating WWNN/MAC list --> $destworkBook "
            writeto-Excel -data $ValuesArray -sheetName $sheetName -destworkBook $destWorkBook
        }
        else
        {
            write-host -foreground YELLOW "No network adapter found.... Skip generating Excel"
        }
    }

}
else
{
    write-host -foreground YELLOW "No ilo IP nor userName nor password specified. Exit the script"
}


