$arrClients = $replaceMe
R

foreach($computer in $arrClients){


    $computerInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer;
        $thermalState = $computerInfo.ThermalState;
        $powerSupplyState = $computerInfo.PowerSupplyState;
        $computerStatus = $computerInfo.Status;

    $driveInfo = Get-PhysicalDisk 
        $driveHealth = $driveInfo.HealthStatus;


    $processorInfo = Get-WmiObject -Class Win32_Processor 
        $cpuStatus = $processorInfo.CpuStatus;
        $cpuVoltage = $processorInfo.CurrentVoltage;

# $fanHealth = Get-WmiObject -Class Win32_Fan | select *

    switch($thermalState)
        {
        1 {$thermalState = "Other"}
        2 {$thermalState = "Unknown"}
        3 {$thermalState = "Safe"}
        4 {$thermalState = "Warning"}
        5 {$thermalState = "Critical"}
        6 {$thermalState = "Non-recoverable"}
        }

    switch($powerSupplyState)
        {
        1 {$powerSupplyState = "Other"}
        2 {$powerSupplyState = "Unknown"}
        3 {$powerSupplyState = "Safe"}
        4 {$powerSupplyState = "Warning"}
        5 {$powerSupplyState = "Critical"}
        6 {$powerSupplyState = "Non-recoverable"}
        }

    switch($cpuStatus){
        1 {$cpuStatus = "OK"}
        2 {$cpuStatus = "Degraded"}
        3 {$cpuStatus = "Critical"}
        4 {$cpuStatus = "Non-recoverable"}
        }



Write-Host "Getting system health report for $computer"
Write-Host "Overrall system health: $computerStatus"
Write-Host "Thermal (temp) state: $thermalState"
Write-Host "PSU state: $powerSupplyState"
Write-Host "CPU status: $cpuStatus"
Write-Host "CPU voltage: $cpuVoltage V"
Write-Host "Disk status: $driveHealth"
Write-Host " "


}
