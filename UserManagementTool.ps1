﻿[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

function Intilialize-Script(){

$cred = Get-Credential -Message 'Please type domain administrator credentials'
$session_option = New-PSSessionOption -IdleTimeout 300000
$global:session = New-PSSession -ComputerName $replaceMe -Credential ($cred) -SessionOption $session_option


Invoke-Command $session -scriptblock {Import-Module ActiveDirectory} | out-null
Import-PSSession -Session $session -Module ActiveDirectory -AllowClobber | out-null

}

# initialize the pssession for the AD tool
# note: connects to DCS1 with 

Intilialize-Script



function ConvertTo-DataTable
{
    <#
    .Synopsis
        Creates a DataTable from an object
    .Description
        Creates a DataTable from an object, containing all properties (except built-in properties from a database)
    .Example
        Get-ChildItem| Select Name, LastWriteTime | ConvertTo-DataTable
    .Link
        Select-DataTable
    .Link
        Import-DataTable
    .Link
        Export-Datatable
    #> 
    [OutputType([Data.DataTable])]
    param(
    # The input objects
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)]
    [PSObject[]]
    $InputObject
    ) 
 
    begin { 
        
        $outputDataTable = new-object Data.datatable   
          
        $knownColumns = @{}
        
        
    } 

    process {         
               
        foreach ($In in $InputObject) { 
            $DataRow = $outputDataTable.NewRow()   
            $isDataRow = $in.psobject.TypeNames -like "*.DataRow*" -as [bool]

            $simpleTypes = ('System.Boolean', 'System.Byte[]', 'System.Byte', 'System.Char', 'System.Datetime', 'System.Decimal', 'System.Double', 'System.Guid', 'System.Int16', 'System.Int32', 'System.Int64', 'System.Single', 'System.UInt16', 'System.UInt32', 'System.UInt64')

            $SimpletypeLookup = @{}
            foreach ($s in $simpleTypes) {
                $SimpletypeLookup[$s] = $s
            }            
            
            
            foreach($property in $In.PsObject.properties) {   
                if ($isDataRow -and 
                    'RowError', 'RowState', 'Table', 'ItemArray', 'HasErrors' -contains $property.Name) {
                    continue     
                }
                $propName = $property.Name
                $propValue = $property.Value
                $IsSimpleType = $SimpletypeLookup.ContainsKey($property.TypeNameOfValue)

                if (-not $outputDataTable.Columns.Contains($propName)) {   
                    $outputDataTable.Columns.Add((
                        New-Object Data.DataColumn -Property @{
                            ColumnName = $propName
                            DataType = if ($issimpleType) {
                                $property.TypeNameOfValue
                            } else {
                                'System.Object'
                            }
                        }
                    ))
                }                   
                
                $DataRow.Item($propName) = if ($isSimpleType -and $propValue) {
                    $propValue
                } elseif ($propValue) {
                    [PSObject]$propValue
                } else {
                    [DBNull]::Value
                }
                
            }   
            $outputDataTable.Rows.Add($DataRow)   
        } 
        
    }  
      
    end 
    { 
        ,$outputDataTable

    } 
 
}

$vers = "1.0"

$nl = "`r`n"

# AAA User OU distinguished name path, where the account is inactive
$aaaOU = Get-ADUser -Filter * -SearchBase $replaceMe -Properties *

# Admin Accounts OU distinguished name path, where the account is inactive
$adminOU = Get-ADUser -Filter * -SearchBase $replaceMe -Properties *

# Domain Admin Accounts OU distinguished name path, where the account is inactive
$domainOU = Get-ADUser -Filter * -SearchBase $replaceMe -Properties *

# User Accounts OU distinguished name path, where the account is inactive
$userOU = Get-ADUser -Filter * -SearchBase $replaceMe -Properties *

# PUS Accounts OU distinguished name path, where the account is inactive
$pusOU = Get-ADUser -Filter * -SearchBase $replaceMe -Properties *

# User Accounts (Outside of CNDS) OU distinguished name path, where the account is inactive
$externaluserOU = Get-ADUser -Filter * -SearchBase '$replaceMe' -Properties *

# AAA User OU distinguished name path, where the account is disabled
$aaaOU_DisabledUsers = Get-ADUser -Filter * -SearchBase $replaceMe |
    where {$_.Enabled -eq $false}

# Admin Accounts OU distinguished name path, where the account is disabled
$adminOU_DisabledUsers = Get-ADUser -Filter * -SearchBase $replaceMe |
    where {$_.Enabled -eq $false}

# Domain Admin Accounts OU distinguished name path, where the account is disabled
$domainOU_DisabledUsers = Get-ADUser -Filter * -SearchBase $replaceMe |
    where {$_.Enabled -eq $false}

# User Accounts OU distinguished name path, where the account is disabled
$userOU_DisabledUsers = Get-ADUser -Filter * -SearchBase $replaceMe |
    where {$_.Enabled -eq $false}

# PUS Accounts OU distinguished name path, where the account is disabled
$pusOU_DisabledUsers = Get-ADUser -Filter * -SearchBase $replaceMe |
    where {$_.Enabled -eq $false}

function Move-DisabledAccounts
{
    
    # Scans all users in AAA Admins for disabled accounts, then moves them to disabled
    # users OU. Writes to console for visual confirmation.
    New-Line
    $outputbox.Text += "Scanning Admin OU for disabled users..."
    New-Line

    if($aaaOU_DisabledUsers.Count -eq 0){
        $outputbox.Text += "No disabled users found."
    }
    else{
        foreach($user in $aaaOU_DisabledUsers){
            $outputbox.Text += "Moving disabled user " + $user.ToString().Split(',')[0].Replace("CN=","") + "."
            Move-ADObject -Identity $user -TargetPath $disabledUsersOU}
    }
    

    # Scans all users in AAA Admins for disabled accounts, then moves them to disabled
    # users OU. Writes to console for visual confirmation.
    New-Line
    $outputbox.Text += "Scanning AAA OU for disabled users..."
    New-Line
    if($adminOU_DisabledUsers.Count -eq 0){
        $outputbox.Text += "No disabled users found."
    }
    else{
        foreach($user in $adminOU_DisabledUsers){
            $outputbox.Text += "Moving disabled user " + $user.ToString().Split(',')[0].Replace("CN=","") + "."
            Move-ADObject -Identity $user -TargetPath $disabledUsersOU}
    }


    # Scans all users in AAA Admins for disabled accounts, then moves them to disabled
    # users OU. Writes to console for visual confirmation.
    New-Line
    $outputbox.Text += "Scanning Domain Admins OU for disabled users..."
    New-Line
    if($domainOU_DisabledUsers.Count -eq 0){
        $outputbox.Text += "No disabled users found."
    }
    else{
        foreach($user in $domainOU_DisabledUsers){
            $outputbox.Text += "Moving disabled user " + $user.ToString().Split(',')[0].Replace("CN=","") + "."
            Move-ADObject -Identity $user -TargetPath $disabledUsersOU}
    }


    # Scans all users in AAA Admins for disabled accounts, then moves them to disabled
    # users OU. Writes to console for visual confirmation.
    New-Line
    $outputbox.Text += "Scanning Users OU for disabled users..."
    New-Line
    if($userOU_DisabledUsers.Count -eq 0){
        $outputbox.Text += "No disabled users found."
    }
    else{
        foreach($user in $userOU_DisabledUsers){
            $outputbox.Text += "Moving disabled user " + $user.ToString().Split(',')[0].Replace("CN=","") + "."
            Move-ADObject -Identity $user -TargetPath $disabledUsersOU}
    }


    # Scans all users in AAA Admins for disabled accounts, then moves them to disabled
    # users OU. Writes to console for visual confirmation.
    New-Line
    $outputbox.Text += "Scanning PUS OU for disabled users..."
    New-Line
    if($pusOU_DisabledUsers.Count -eq 0){
        $outputbox.Text += "No disabled users found."
    }
    else{
        foreach($user in $pusOU_DisabledUsers){
            $outputbox.Text += "Moving disabled user " + $user.ToString().Split(',')[0].Replace("CN=","") + "."
            Move-ADObject -Identity $user -TargetPath $disabledUsersOU}
    }

}

$arrOU = @()
$arrOU = ($aaaOU, $adminOU, $domainOU, $userOU,
$pusOU, $externaluserOU)

$date = Get-Date

# declare initial form object

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(420,730)
$form.Text = "User Management Tool $vers"
$form.BackColor = "DarkGray"
$form.Font = "Tahoma"
$form.MaximizeBox = $false
$form.add_FormClosing({Remove-PSSession -Session $session;
                           Write-Host 'Closed DCS1 PSSession.'; })
$form.FormBorderStyle = "FixedDialog"

function Get-InactiveUsers{
$inactiveUserCount = 0
$userReport = @()
if($gridview.DataSource -ne $null){
    $gridview.DataSource = $null
    }

foreach($ou in $arrOU){
    foreach($user in $ou){
    
        if($user.LastLogonDate -le ($date.AddDays(-30))){
        $inactiveUserCount += 1
        $userInfo = Get-ADUser -Identity $user.ToString().Split(',')[0].Replace("CN=","") -Properties * |
            select SamAccountName,{$user.LastLogonDate},Name
        $userReport += $userInfo
        $outputBox.Text += $user.ToString().Split(",")[0].Replace("CN=","")
        $outputBox.AppendText($nl)
        }
        else{
             
    }
}
}


if($userReport -ne $null){

$gridview.DataSource = $userReport | ConvertTo-DataTable
New-Line
$outputbox.Text += "Succesfully displayed " + $inactiveUserCount + " inactive users."
$outputbox.AppendText($nl)

}
else{
[System.Windows.Forms.MessageBox]::Show("No inactive users")
New-Line
$outputbox.Text += "Displaying " + $inactiveUserCount + " inactive users."
$outputbox.AppendText($nl)
}

}


# declare button to report all inactive users in all OUs in domain
$btnReport = New-Object System.Windows.Forms.Button
$btnReport.Location = New-Object System.Drawing.Size(10, 10)
$btnReport.Text = "Report Inactive Users"
$btnReport.AutoSize = $true
$btnReport.Add_Click({Get-InactiveUsers})
$form.Controls.Add($btnReport)

function Disable-InactiveUsers{
$inactiveUserCount = 0
foreach($ou in $arrOU){
        foreach($user in $ou){

            if($user.LastLogonDate -le $date.AddDays(-30)){
                if(!($user.lastLogonDate -eq $null)){
                $inactiveUserCount += 1
                Disable-ADAccount -Identity $user
                $strUser = $user.ToString().Split(",")[0].Trim("CN=")
                $outputbox.Text += "Disabled " + $strUser
                $outputbox.AppendText($nl)
                }
                else{
                $inactiveUserCount += 1
                Disable-ADAccount -Identity $user
                $strUser = $user.ToString().Split(",")[0].Trim("CN=")
                $outputbox.Text += "Disabled " + $strUser
                $outputbox.AppendText($nl)
                }
            }
           
        }
}

New-Line
$outputbox.Text += "Disabled " + $inactiveUserCount + " total users."
Get-InactiveUsers

}

# declare button to disable all inactive accounts

$btnDisable = New-Object System.Windows.Forms.Button
$btnDisable.Location = New-Object System.Drawing.Size(140, 10)
$btnDisable.AutoSize = $true
$btnDisable.Text = "Disable Inactive Users"
$btnDisable.Add_Click({Disable-InactiveUsers})
$form.Controls.Add($btnDisable)



# declare button to move all disabled users to disabled users OU


$btnMove = New-Object System.Windows.Forms.Button
$btnMove.Location = New-Object System.Drawing.Size(275, 10)
$btnMove.AutoSize = $true
# $btnMove.Enabled = $false
$btnMove.Text = "Move Disabled Users"
$btnMove.Add_Click({Move-DisabledAccounts})
$form.Controls.Add($btnMove)



# declare data grid view
$gridview = New-Object System.Windows.Forms.DataGridView
$gridview.Location = New-Object System.Drawing.Size(10, 50)
$gridview.Height = 300
$gridview.Width = 388
$gridview.BackColor = "LightGray"
$gridview.ColumnHeadersVisible = $false;
$gridview.AllowUserToResizeColumns = $true;
$gridview.AllowUserToAddRows = $false;
$gridview.AllowUserToResizeRows = $true;
$gridview.RowHeadersVisible = $false;
$gridview.ReadOnly = $true
$gridview.MultiSelect = $true
$form.Controls.Add($gridview)




# declare read-only output textbox (rich)
$outputbox = New-Object System.Windows.Forms.RichTextBox
$outputbox.Location = New-Object System.Drawing.Size(10, 370)
$outputbox.Height = 300
$outputbox.Width = 388
$outputbox.ReadOnly = $true
$outputbox.BackColor = "LightGray"
$form.Controls.Add($outputbox)

function New-Line{

$outputbox.Text += " "
$outputbox.AppendText($nl)

}

# ENTRY POINT OF FORM
$form.ShowDialog()


