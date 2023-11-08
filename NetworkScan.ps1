function Get-OS($pc){

$os = (Get-WmiObject -ComputerName $pc -Class Win32_OperatingSystem).Caption

return $os

}

function Discover-Machines{

[System.Collections.ArrayList]$arrDiscoveredMachines = @()

$subnet = "192.168.1."

for($i = 0; $i -le 255; $i++){

$ip = $subnet + $i

if(!(Test-Connection $ip -Quiet -Count 1)){

Write-Host "False"

}
else{

write-host "True"
    
    
    try{
        
        Resolve-DnsName -Server $dns -Name $ip
        Get-OS($ip)
    }
    catch{
        
        Write-Host "Unable to resolve DNS name for $ip"
    }

$arrDiscoveredMachines.Add($ip)

}


}

return $arrDiscoveredMachines

}


Discover-Machines


$machines = ("192.168.1.78",
"192.168.1.80",
"192.168.1.85",
"192.168.1.86",
"192.168.1.115",
"192.168.1.125",
"192.168.1.185",
"192.168.1.186",
"192.168.1.204",
"192.168.1.242",
"192.168.1.254")


