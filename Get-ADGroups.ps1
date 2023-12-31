﻿
function Intilialize-Script(){

$cred = Get-Credential -Message 'Please type domain administrator credentials'
$options = New-PSSessionOption -IdleTimeout 300000
$global:session = New-PSSession -ComputerName $replaceMe -Credential ($cred) -SessionOption $options


Invoke-Command $session -scriptblock {Import-Module ActiveDirectory} | out-null
Import-PSSession -Session $session -Module ActiveDirectory -AllowClobber | out-null

}

# initialize the pssession for the AD tool
# note: connects to DCS1 with 

Intilialize-Script


$groups = $replaceMe, $replaceMe;

foreach($group in $groups){

	$users = Get-ADGroupMember -Identity $group
	    foreach($user in $users)
        {

		    Get-ADUser -Identity $user -Properties * |
		    select Name,Enabled,PasswordLastSet
        }	
}




function Cleanup-Session
{

Remove-PSSession -Session $session

}
