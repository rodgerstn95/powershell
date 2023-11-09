cls

$ADSession = New-PSSession -ComputerName $server -Credential (Get-Credential)
Invoke-Command $ADSession -scriptblock { Import-Module ActiveDirectory } | out-null
Import-PSSession -Session $ADSession -Module ActiveDirectory -AllowClobber | out-null

function ContinueScript{
    Write-Host 'Run script for another account? [y/n]' -ForegroundColor Yellow -BackgroundColor Black
    $answer = Read-Host '>>>'
    if ($answer -match 'y'){
        cls
        username
    }
    else{
        cls
        break
    }
}

function logic{
    if ($num -eq 1){
        cls
        Set-ADAccountPassword -Identity $user -NewPassword $NewPassword -Reset
        Unlock-ADAccount -Identity $user
        write-host "Password has been changed." -ForegroundColor Green -BackgroundColor Black
        ContinueScript    
    }
    if ($num -eq 2){
        cls
     Unlock-ADAccount -Identity $user
        write-host "Account has been unlocked." -ForegroundColor Green -BackgroundColor Black
        ContinueScript
    }
}

function Username{
    Write-Host 'Please enter your username' -ForegroundColor Yellow -BackgroundColor Black
    $global:user = Read-Host '>>>'
    $global:Query = Get-ADUser -Filter "SamAccountName -eq '$user'"
    if ($Query -ne $null){
        cls
        $status = get-aduser -Identity $user | Select-Object Enabled -ExpandProperty Enabled
        if ($status -eq $true){
            Write-Host "$user is currently enabled" -ForegroundColor Green -BackgroundColor Black
        }
        else{
            Write-Host "$user is currently disabled" -ForegroundColor Red -BackgroundColor black
        }
        write-host "Enter [1] to change password" -ForegroundColor Yellow -BackgroundColor Black
        write-host "Enter [2] to change unlocked" -ForegroundColor Yellow -BackgroundColor Black
        $global:num = read-host '>>>'
        logic
    }
    else{
        Write-Host "Please enter a vlaid username." -ForegroundColor Red -BackgroundColor Black
        Username
    }
}

username
