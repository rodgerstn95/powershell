
function Intilialize-Script(){

$cred = Get-Credential -Message 'Please type domain administrator credentials'
$session_option = New-PSSessionOption -IdleTimeout 300000
$global:session = New-PSSession -ComputerName $replaceMe -Credential ($cred) -SessionOption $session_option


Invoke-Command $session -scriptblock {Import-Module ActiveDirectory} | out-null
Import-PSSession -Session $session -Module ActiveDirectory -AllowClobber | out-null

}

# initialize the pssession for the AD tool
# note: connects to $replaceMe with 

Intilialize-Script

# CHANGE THIS VARIABLE TO BE YOUR ADMIN USERNAME
$user = $replaceMe

# Distinguished name path to the system admins OU
$AdminOU = $replaceMe

# Distinguished name path to the domain admins OU
$DomainOU = '$replaceMe

# Distinguished name path to the AAA network admins OU
$AAAOU = $replaceMe

# Distinguished name path to the patch update server admins OU
$PUSOU = $replaceMe

# function that grabs users in specified OUs and outputs them to text file in a PAAR folder on the admin users
# desktop. Location can be changed
function Get-AdminUsers(){

Get-ADUser -Filter * -SearchBase $AdminOU |
    Select-Object SamAccountName,Enabled,LastLogonTime |
    Out-String |
    Format-Table -AutoSize |
    Out-File $replaceMe

Get-ADUser -Filter * -SearchBase $DomainOU |
    Select-Object SamAccountName,Enabled |
    Out-String |
    Out-File $replaceMe

Get-ADUser -Filter * -SearchBase $AAAOU |
    Select-Object SamAccountName,Enabled,Name |
    Out-String |
    Out-File $replaceMe

Get-ADUser -Filter * -SearchBase $PUSOU |
    Select-Object SamAccountName,Enabled |
    Out-String |
    Out-File $replaceMe

    }


# entry point of powershell script (actual function runs here)
Get-AdminUsers
