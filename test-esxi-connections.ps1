# ESXI TEST CONNECTION SCRIPT
# Author: IT2 Rodgers
# 
# Function: tests connection of all ESXI hosts in the CND cluster while HA (High availability) is currently not working
# will return a boolean (true or false) value and output the result as friendly text to the console in pretty colors for
# your reading pleasure.



# declare function
function test-esxi-connections{

# clear console screen of extra text
cls

$currentsystem = $env:COMPUTERNAME

# get current logged on user in environment and store it in currentuser variable
$currentuser = $env:USERNAME

# set $date variable equal to current date for logging/reporting purposes
$date = Get-Date

# set path to logfile for script execution
$logfile = 'D:\logs\esxilog.txt'

# set message to be written to log file (.txt)
$message = $currentsystem + ' - Script succesfully ran on ' + $date + ' by ' + $currentuser

# initialize nodes variable as an array
$nodes = @()

# populate nodes array with hostnames of ESX servers
$nodes = $replaceMe

# initialize foreach loop to iterate through each server in the nodes array
foreach($node in $nodes){

#set status variable equal to the boolean return of the Test-Connection commandlet for each node
$status = Test-Connection -ComputerName $node -Count 3 -Quiet
    
    # if loop to test whether the function is going to return true or false
    if($status -eq 'True'){

        Write-Host $node 'is online as of' $date -ForegroundColor Green


    }
    # else of if statement
    else{

        Write-Host $node 'is offline. Please call IT2 Rodgers at 080-7596-6995 immediately and contact CDO.' -ForegroundColor Red
    }
}

$message >> $logfile;

}

# exit



# ENTRY POINT HERE

test-esxi-connections

Read-Host 'Press enter to exit'
