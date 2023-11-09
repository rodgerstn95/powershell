cls
$cred = get-credential -Message 'Please enter your domain admin credentials'
$ADSession = New-PSSession -ComputerName $server -Credential ($cred)
$PSSessionID = $ADSession.Id

Invoke-Command $ADSession -scriptblock { Import-Module ActiveDirectory } | out-null

Import-PSSession -Session $ADSession -Module ActiveDirectory -AllowClobber | out-null

$DomAccounts = Get-ADUser -SearchBase $fqdn
$AdmAccounts = Get-ADUser -SearchBase $fqdn
$UsrAccounts = Get-ADUser -SearchBase $fqdn
$AAAaccounts = Get-ADUser -SearchBase $fqdn
$PusAccounts = Get-ADUser -SearchBase $fqdn | select -property SamAccountName

function Create-Dom-Acct{
    $NewDomAcct = "$NewUsrFirst.$NewUsrLast.dom".ToLower()
    New-ADUser `
        -Name "$NewUsr dom" `
        -SamAccountName $NewDomAcct `
        -GivenName $NewUsrFirst `
        -Surname $NewUsrLast `
        -Enabled $AcctEnCheckBox.Checked `
        -AccountPassword $NewUsrPass `
        -ChangePasswordAtLogon $ChgePassCheckBox.Checked `
        -Path $fqdn
    Get-ADUser -Identity $DomTemplateBox.Text -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Add-ADGroupMember -Members $NewDomAcct
    $Usr = [bool] (Get-ADUser -Properties SamAccountName "$NewDomAcct") 
    if ($Usr -eq $true){
        $OutputBox.Text += $NewDomAcct + " was successfully Created! `r`n"
    }
    else{
        $OutputBox.Text += $NewDomAcct + " was not created. `r`n"
    }
}

function Create-Adm-Acct{
    $NewAdmAcct = "$NewUsrFirst.$NewUsrLast.adm".ToLower()
    New-ADUser `
        -Name "$NewUsr adm" `
        -SamAccountName $NewAdmAcct `
        -GivenName $NewUsrFirst `
        -Surname $NewUsrLast `
        -Enabled $AcctEnCheckBox.Checked `
        -AccountPassword $NewUsrPass `
        -ChangePasswordAtLogon $ChgePassCheckBox.Checked `
        -Path "OU=Administrative User Accounts,OU=Users,OU=CNDS,DC=feyo,DC=onenet,DC=oob,DC=navy,DC=mil"
    Get-ADUser -Identity $AdmTemplateBox.Text -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Add-ADGroupMember -Members $NewAdmAcct
    $Usr = [bool] (Get-ADUser -Properties SamAccountName "$NewAdmAcct")
    if ($Usr -eq $true){
        $OutputBox.Text += "$NewAdmAcct was successfully Created! `r`n"
    }
    else{
        $OutputBox.Text += "$NewAdmAcct was not created. `r`n"
    }
}

function Create-Usr-Acct{
    $NewUsrAcct = "$NewUsrFirst.$NewUsrLast.usr".ToLower()
    New-ADUser `
        -Name "$NewUsr usr" `
        -SamAccountName $NewUsrAcct `
        -GivenName $NewUsrFirst `
        -Surname $NewUsrLast `
        -Enabled $AcctEnCheckBox.Checked `
        -AccountPassword $NewUsrPass `
        -ChangePasswordAtLogon $ChgePassCheckBox.Checked `
        -Path $replaceme
    Get-ADUser -Identity $UsrTemplateBox.Text -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Add-ADGroupMember -Members $NewUsrAcct
    $Usr = [bool] (Get-ADUser -Properties SamAccountName "$NewUsrAcct")
    if ($Usr -eq $true){
        $OutputBox.Text += "$NewUsrAcct was successfully Created! `r`n"
    }
    else{
        $OutputBox.Text += "$NewUsrAcct was not created. `r`n"
    }
}

function Create-AAA-Acct{
    $FirstInitial = $NewUsrFirst[0]
    $NewAAAacct = "$NewUsrLast$firstInitial".ToLower()
    New-ADUser `
        -Name "$NewUsr aaa" `
        -SamAccountName $NewAAAacct `
        -GivenName $NewUsrFirst `
        -Surname $NewUsrLast `
        -Enabled $AcctEnCheckBox.Checked `
        -AccountPassword $NewUsrPass `
        -ChangePasswordAtLogon $ChgePassCheckBox.Checked `
        -Path $replacemme
    Get-ADUser -Identity $AAATemplateBox.Text -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Add-ADGroupMember -Members $NewAAAacct
    $Usr = [bool] (Get-ADUser -Properties SamAccountName "$NewAAAacct")
    if ($Usr -eq $true){
        $OutputBox.Text += "$NewAAAacct was successfully Created! `r`n"
    }
    else{
        $OutputBox.Text += "$NewAAAacct was not created. `r`n"
    }
}

function Create-Pus-Acct{
    $NewPusAcct = "$NewUsrFirst.$NewUsrLast.pus".ToLower()
    New-ADUser `
        -Name "$NewUsr pus" `
        -SamAccountName $NewPusAcct `
        -GivenName $NewUsrFirst `
        -Surname $NewUsrLast `
        -Enabled $AcctEnCheckBox.Checked `
        -AccountPassword $NewUsrPass `
        -ChangePasswordAtLogon $ChgePassCheckBox.Checked `
        -Path $replaceMe
    Get-ADUser -Identity $PusTemplateBox.Text -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Add-ADGroupMember -Members $NewPusAcct
    $Usr = [bool] (Get-ADUser -Properties SamAccountName "$NewPusAcct")
    if ($Usr -eq $true){
        $OutputBox.Text += "$NewPusAcct was successfully Created! `r`n"
    }
    else{
        $OutputBox.Text += "$NewPusAcct was not created. `r`n"
    }
}

function Set-Variables{
    $global:NewUsr = $NameBox.Text
    $global:NewUsrFirst = $NewUsr.Split(" ")[0]
    $global:NewUsrLast = $NewUsr.Split(" ")[1]
    $global:NewUsrPass = ConvertTo-SecureString $PswdBox.Text -AsPlainText -Force
    $OutputBox.Text += "The Following actions have taken place:`r`n"
    $OutputBox.Text += "`r`n"

    while ($DomAcctCheckBox.Checked -eq $true){
        if ($DomTemplateBox.Text -ilike ""){
            $OutputBox.Text += "Please Select a dom account to copy. `r`n"
            break
        }
        else{
            Create-Dom-Acct
            break
        }
    }
    while ($AdmAcctCheckBox.Checked -eq $true){
        if ($AdmTemplateBox.Text -ilike ""){
            $OutputBox.Text += "Please Select a adm account to copy. `r`n"
            break
        }
        else{
            Create-Adm-Acct
            break
        }
    }
    while ($UsrAcctCheckBox.Checked -eq $true){
        if ($UsrTemplateBox.Text -ilike ""){
            $OutputBox.Text += "Please Select a usr account to copy. `r`n"
            break
        }
        else{
            Create-Usr-Acct
            break
        }
    }
    while ($AAAacctCheckBox.Checked -eq $true){
        if ($AAATemplateBox.Text -ilike ""){
            $OutputBox.Text += "Please Select a AAA account to copy. `r`n"
            break
        }
        else{
            Create-AAA-Acct
            break
        }
    }
    while ($PusAcctCheckBox.Checked -eq $true){
        if ($PusTemplateBox.Text -ilike ""){
            $OutputBox.Text += "Please Select a pus account to copy. `r`n"
            break
        }
        else{
            Create-Pus-Acct
            break
        }
    }          
}

$form = New-Object System.Windows.Forms.Form
    $form.text = "Create AD Users" 
    $form.Size = New-Object System.Drawing.Size(1000,500)
    $form.FormBorderStyle = "FixedDialog"
    $form.MinimizeBox = $true
    $form.MaximizeBox = $false
    $form.SizeGripStyle = "Hide"
    $form.StartPosition = "CenterScreen"
    $form.BackColor = "DarkGray"

$DomAcctCheckBox = New-Object System.Windows.Forms.CheckBox
    $DomAcctCheckBox.Location = New-Object System.Drawing.Size(5,135)
    $DomAcctCheckBox.size = New-Object System.Drawing.Size(200,25)
    $DomAcctCheckBox.Text = " Create Domain Account"
    $DomAcctCheckBox.Add_Click({
        if ($DomAcctCheckBox.Checked  -eq $true){
            $DomTemplateBox.Enabled = $true
        }
        else{
            $DomTemplateBox.Enabled = $false
        }
    })
    $form.Controls.Add($DomAcctCheckBox)

$AdmAcctCheckBox = New-Object System.Windows.Forms.CheckBox
    $AdmAcctCheckBox.Location = New-Object System.Drawing.Size(5,190)
    $AdmAcctCheckBox.size = New-Object System.Drawing.Size(200,25)
    $AdmAcctCheckBox.Text = " Create Admin Account"
    $AdmAcctCheckBox.Add_Click({
        if ($AdmAcctCheckBox.Checked  -eq $true){
            $AdmTemplateBox.Enabled = $true
        }
        else{
            $AdmTemplateBox.Enabled = $false
        }
    })
    $form.Controls.Add($AdmAcctCheckBox)

$UsrAcctCheckBox = New-Object System.Windows.Forms.CheckBox
    $UsrAcctCheckBox.Location = New-Object System.Drawing.Size(5,245)
    $UsrAcctCheckBox.size = New-Object System.Drawing.Size(200,25)
    $UsrAcctCheckBox.Text = " Create User Account"
    $UsrAcctCheckBox.Add_Click({
        if ($UsrAcctCheckBox.Checked  -eq $true){
            $UsrTemplateBox.Enabled = $true
        }
        else{
            $UsrTemplateBox.Enabled = $false
        }
    })
    $form.Controls.Add($UsrAcctCheckBox)

$AAAacctCheckBox = New-Object System.Windows.Forms.CheckBox
    $AAAacctCheckBox.Location = New-Object System.Drawing.Size(5,300)
    $AAAacctCheckBox.size = New-Object System.Drawing.Size(200,25)
    $AAAacctCheckBox.Text = " Create AAA Account"
    $AAAacctCheckBox.Add_Click({
        if ($AAAacctCheckBox.Checked  -eq $true){
            $AAATemplateBox.Enabled = $true
        }
        else{
            $AAATemplateBox.Enabled = $false
        }
    })
    $form.Controls.Add($AAAacctCheckBox)

$PusAcctCheckBox = New-Object System.Windows.Forms.CheckBox
    $PusAcctCheckBox.Location = New-Object System.Drawing.Size(5,355)
    $PusAcctCheckBox.size = New-Object System.Drawing.Size(200,25)
    $PusAcctCheckBox.Text = " Create PUS Account"
    $PusAcctCheckBox.Add_Click({
        if ($PusAcctCheckBox.Checked  -eq $true){
            $PusTemplateBox.Enabled = $true
        }
        else{
            $PusTemplateBox.Enabled = $false
        }
    })
    $form.Controls.Add($PusAcctCheckBox)

$AcctEnCheckBox = New-Object System.Windows.Forms.CheckBox
    $AcctEnCheckBox.Location = New-Object System.Drawing.Size(230,390)
    $AcctEnCheckBox.Height = 25
    $AcctEnCheckBox.Width = 150
    $AcctEnCheckBox.Text = " Enable Account(s)"
    $AcctEnCheckBox.Checked = $true
    $form.Controls.Add($AcctEnCheckBox)

$ChgePassCheckBox = New-Object System.Windows.Forms.CheckBox
    $ChgePassCheckBox.Location = New-Object System.Drawing.Size(380,390)
    $ChgePassCheckBox.Width = 230
    $ChgePassCheckBox.Height = 25
    $ChgePassCheckBox.Text = " Change password at next login"
    $form.Controls.Add($ChgePassCheckBox)

$NameBox = New-Object System.Windows.Forms.TextBox
    $NameBox.Location = New-Object System.Drawing.Size(310,25)
    $NameBox.Width = 200
    $NameBox.Font = New-Object System.Drawing.Font ("Default",12)
    $form.Controls.Add($NameBox)

$PswdBox = New-Object System.Windows.Forms.MaskedTextBox
    $PswdBox.Location = New-Object System.Drawing.Size(310,80)
    $PswdBox.Width = 200
    $PswdBox.Font = New-Object System.Drawing.Font ("Default",12)
    $PswdBox.PasswordChar = '$'
    $form.Controls.Add($PswdBox)

$DomTemplateBox = New-Object System.Windows.Forms.ComboBox
    $DomTemplateBox.Items.AddRange($DomAccounts)
    $DomTemplateBox.Sorted = $true
    $DomTemplateBox.Location = New-Object System.Drawing.Size(310,135)
    $DomTemplateBox.Width = 200
    $DomTemplateBox.Enabled = $false
    $DomTemplateBox.Font = New-Object System.Drawing.Font ("Default",12)
    $form.Controls.Add($DomTemplateBox)

$AdmTemplateBox = New-Object System.Windows.Forms.ComboBox
    $AdmTemplateBox.Items.AddRange($AdmAccounts)
    $AdmTemplateBox.Sorted = $true
    $AdmTemplateBox.Location = New-Object System.Drawing.Size(310,190)
    $AdmTemplateBox.Width = 200
    $AdmTemplateBox.MaxLength = 10
    $AdmTemplateBox.Enabled = $false
    $AdmTemplateBox.Font = New-Object System.Drawing.Font ("Default",12)
    $form.Controls.Add($AdmTemplateBox)

$UsrTemplateBox = New-Object System.Windows.Forms.ComboBox
    $UsrTemplateBox.Items.AddRange($UsrAccounts)
    $UsrTemplateBox.Sorted = $true
    $UsrTemplateBox.Location = New-Object System.Drawing.Size(310,245)
    $UsrTemplateBox.Width = 200
    $UsrTemplateBox.MaxLength = 10
    $UsrTemplateBox.Enabled = $false
    $UsrTemplateBox.Font = New-Object System.Drawing.Font ("Default",12)
    $form.Controls.Add($UsrTemplateBox)

$AAATemplateBox = New-Object System.Windows.Forms.ComboBox
    $AAATemplateBox.Items.AddRange($AAAaccounts)
    $AAATemplateBox.Sorted = $true
    $AAATemplateBox.Location = New-Object System.Drawing.Size(310,300)
    $AAATemplateBox.Width = 200
    $AAATemplateBox.Enabled = $false
    $AAATemplateBox.Font = New-Object System.Drawing.Font ("Default",12)
    $form.Controls.Add($AAATemplateBox)

$PusTemplateBox = New-Object System.Windows.Forms.ComboBox
    $PusTemplateBox.Items.AddRange($PusAccounts)
    $PusTemplateBox.Sorted = $true
    $PusTemplateBox.Location = New-Object System.Drawing.Size(310,355)
    $PusTemplateBox.Width = 200
    $PusTemplateBox.Enabled = $false
    $PusTemplateBox.Font = New-Object System.Drawing.Font ("Default",12)
    $form.Controls.Add($PusTemplateBox)

$OutputBox = New-Object System.Windows.Forms.TextBox 
    $OutputBox.Location = New-Object System.Drawing.Size(620,25) 
    $OutputBox.Width = 375
    $OutputBox.Height = 440
    $OutputBox.MultiLine = $True 
    $OutputBox.ScrollBars = "Vertical"
    $OutputBox.BackColor = "Black"
    $OutputBox.ForeColor = "Green"
    $OutputBox.Font = New-Object System.Drawing.Font ("Default",12,[System.Drawing.FontStyle]::Bold)
    $Form.Controls.Add($OutputBox)

$NameBoxLabel = New-Object System.Windows.Forms.Label
    $NameBoxLabel.text = "Please enter your first and last name:"
    $NameBoxLabel.Location = New-Object System.Drawing.Size(290,5)
    $NameBoxLabel.Width = 250
    $form.Controls.Add($NameBoxLabel)

$PswdBoxLabel = New-Object System.Windows.Forms.Label
    $PswdBoxLabel.text = "Please enter your password:"
    $PswdBoxLabel.Location = New-Object System.Drawing.Size(317,60)
    $PswdBoxLabel.Width = 200
    $form.Controls.Add($PswdBoxLabel)

$DomBoxLabel = New-Object System.Windows.Forms.Label
    $DomBoxLabel.text = "Please select the dom account you wish to copy (If Applicable):"
    $DomBoxLabel.Location = New-Object System.Drawing.Size(220,115)
    $DomBoxLabel.Width = 400
    $form.Controls.Add($DomBoxLabel)

$AdmBoxLabel = New-Object System.Windows.Forms.Label
    $AdmBoxLabel.text = "Please select the adm account you wish to copy (If Applicable):"
    $AdmBoxLabel.Location = New-Object System.Drawing.Size(220,170)
    $AdmBoxLabel.Width = 400
    $form.Controls.Add($AdmBoxLabel)

$UsrBoxLabel = New-Object System.Windows.Forms.Label
    $UsrBoxLabel.text = "Please select the usr account you wish to copy (If Applicable):"
    $UsrBoxLabel.Location = New-Object System.Drawing.Size(220,225)
    $UsrBoxLabel.Width = 400
    $form.Controls.Add($UsrBoxLabel)

$AAABoxLabel = New-Object System.Windows.Forms.Label
    $AAABoxLabel.text = "Please select the AAA account you wish to copy (If Applicable):"
    $AAABoxLabel.Location = New-Object System.Drawing.Size(220,280)
    $AAABoxLabel.Width = 410
    $form.Controls.Add($AAABoxLabel)

$PusBoxLabel = New-Object System.Windows.Forms.Label
    $PusBoxLabel.text = "Please select the PUS account you wish to copy (If Applicable):"
    $PusBoxLabel.Location = New-Object System.Drawing.Size(220,335)
    $PusBoxLabel.Width = 410
    $form.Controls.Add($PusBoxLabel)

$OutputBoxLabel = New-Object System.Windows.Forms.Label
    $OutputBoxLabel.text = "Output:"
    $OutputBoxLabel.Location = New-Object System.Drawing.Size(775,5)
    $OutputBoxLabel.Width = 100
    $form.Controls.Add($OutputBoxLabel)

 $CreateAcctButton = New-Object System.Windows.Forms.Button   
    $CreateAcctButton.Location = New-Object System.Drawing.Size(340,425)
    $CreateAcctButton.ForeColor = "Black"
    $CreateAcctButton.BackColor = 'gray'
    $CreateAcctButton.Text = "Create Account(s)"
    $CreateAcctButton.AutoSize = $true 
    $CreateAcctButton.Add_Click({
        $OutputBox.Text = ""
        Set-Variables
    })
    $form.Controls.Add($CreateAcctButton)

 $CloseWindowButton = New-Object System.Windows.Forms.Button   
    $CloseWindowButton.Location = New-Object System.Drawing.Size(5,5)
    $CloseWindowButton.ForeColor = "Black"
    $CloseWindowButton.BackColor = 'gray'
    $CloseWindowButton.Text = "Exit Application"
    $CloseWindowButton.Height = 30
    $CloseWindowButton.Width = 100
    $CloseWindowButton.Add_Click({
        $form.Close()
    })
    $form.Controls.Add($CloseWindowButton)

[void] $form.ShowDialog() 
Remove-PSSession -Session $ADSession
