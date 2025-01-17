[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
###################################                          The D-2 Wizard                                        ###################################  
###################################                  Developed by: IT2 Rodgers, IT2 Mumme                          ################################### 
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################

# IMPORTANT!!! Make sure Powershell ISE is run as administrator or else the security logs will not populate.

# Declare version of application to indicate changes made

$class = "[UNCLASSIFIED/FOUO]"

$objVers = "4.3.1"


# magic from Powershell gallery to convert GridView Data to Data Table and display within form application

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


<# version changelog
# 1.0 initial form application with button layout and no functionality
# 1.1 added core functionality of all buttons
# 1.2 repositioned buttons on screen for ease of access
# 1.3 repositioned text boxes
# 1.4 added test-connection function and button to get online status of all workstations and return boolean value
# 1.5 changed text boxes to display verbose and streamlined error messages
# 1.6 added power off and reboot buttons
# 1.7 added function to power off and reboot buttons
# 2.0 completely revamped entire design of form application to make it more professional/neat.
# 2.1 added classification sticker/label, updated array to list SIPR workstations
# 2.2 changed message box to display number of workstations online/offline and set console color for offline machines to red for easier readability.
# 2.2.1 changed message of status connection to be more clean and user friendly.
# 2.2.2 added messagebox to display with count of servers online/offline.
# 2.2.2.1 fixed issue with messagebox display inside foreach loop causing 21 boxes to be displayed
# 3.0 revamped output entirely and changed from rich text box to datagrid view. implemented function to convert to datatable and display cleanly within form application
# 3.1 added firefox button to open system administrator page for selected SOC workstation
# 4.0 complete overhaul of entire application. added additionally controls and functionality to more buttons.
# 4.1 complete graphical overhaul of entire application. changed style and color to appear more professional and clean.
# 4.2 added cert check functionality and second combobox for servers.
# 4.2.1 added logic to disable combobox not currently selected to prevent double values from being target object of functions
# 4.2.2 added checkboxes to toggle off functions not needed to prevent accidental actions taken on unintended servers
# 4.2.3 added logic to disable power off and reboot buttons when server combobox is selected to prevent accidental shutdown/reboot of domain servers
# 4.3 complete rewrite of all functions to select only the combobox which radio button is checked. cleaned up 400 lines of uncessary comments and old controls/functions
# 4.3.1 removed SOC library and added get service function to get all services, status, and startup type of a selected SOC/server


#>

# Declare an array of strings representing all SOC workstations. Change this for SIPR/other sites.

$arrClients = ("put an array of all clients here")

$arrServers = ('put an array of all servers here')

# hasthables to store info on SOC workstations and their location
# unsure exactly what info can be stored without violating PII/being a security risk
# very basic info for now, can add more later.
#region SOC hashtables

# Can store credentials in order to authenticate with servers not associated with the domain.

# $credential = Get-Credential

# Declare form variable and set its dimensions/attributes.

$form = New-Object System.Windows.Forms.Form
    $form.text = "SNS Maintenance Wizard $objVers $class"
    $form.Size = New-Object System.Drawing.Size(1280,720)
    $form.FormBorderStyle = "FixedDialog"
    $form.ControlBox = $false
    $form.MinimizeBox = $true
    $form.MaximizeBox = $false
    $form.SizeGripStyle = "Hide"
    $form.BackColor = 'LightGray'
    $form.StartPosition = "CenterScreen"


#region Form Labels

# classification level label

$classLabel = New-Object System.Windows.Forms.Label
    $classLabel.Location = New-Object System.Drawing.Size(20,20)
    $classLabel.ForeColor = "White"
    $classLabel.Font = "Tahoma,20"
    $classLabel.BackColor = "Green"
    $classLabel.AutoSize = $true
    $classLabel.Text = "UNCLASSIFIED"
  # $form.Controls.Add($classLabel)

$selectClientLabel = New-Object System.Windows.Forms.Label
    $selectClientLabel.Location = New-Object System.Drawing.Size(630,7)
    $selectClientLabel.ForeColor = "White"
    $selectClientLabel.Text = "<Select Client"
    $selectClientLabel.AutoSize = $true
    $selectClientLabel.Font = "Tahoma,10"
    $selectClientLabel.BackColor = "Transparent"
  # $form.Controls.Add($selectClientLabel)

# label underneath text box where application logs populate

$sysLabel = New-Object System.Windows.Forms.Label
    $sysLabel.Location = New-Object System.Drawing.Size(170,671)
    $sysLabel.Text = "Application Logs"
    $sysLabel.Font = "Tahoma,9"
    $sysLabel.ForeColor = "Black"
    $form.Controls.Add($sysLabel)

# label underneath text box where system logs populate

$appLabel = New-Object System.Windows.Forms.Label
    $appLabel.Location = New-Object System.Drawing.Size(610,671)
    $appLabel.Text = "System Logs"
    $appLabel.Font = "Tahoma,9"
    $appLabel.ForeColor = "Black"
    $form.Controls.Add($appLabel)

# label underneath text box where security logs populate

$secLabel = New-Object System.Windows.Forms.Label
    $secLabel.Location = New-Object System.Drawing.Size(1050,671)
    $secLabel.Text = "Security Logs"
    $secLabel.Font = "Tahoma,9"
    $secLabel.ForeColor = "Black"
    $form.Controls.Add($secLabel)

$d2label = New-Object System.Windows.Forms.Label
    $d2label.Location = New-Object System.Drawing.Size(40,5)
    $d2label.Font = "Tahoma,9"
    $d2label.Text = 'Toggle D-2 Functions'
    $d2label.BackColor = 'Transparent'
    $d2label.ForeColor = 'Black'
    $d2label.AutoSize = $true
    $form.controls.Add($d2label)


$m1label = New-Object System.Windows.Forms.Label
    $m1label.Location = New-Object System.Drawing.Size(40,25)
    $m1label.Text = 'Toggle M-1 Functions'
    $m1label.Font = "Tahoma,9"
    $m1label.BackColor = "Transparent"
    $m1label.ForeColor = "Black"
    $m1label.AutoSize = $true
    $form.Controls.Add($m1label)


$2m1label = New-Object System.Windows.Forms.Label
    $2m1label.Location = New-Object System.Drawing.Size(40,45)
    $2m1label.Text = 'Toggle 2M-1 Functions'
    $2m1label.Font = "Tahoma,9"
    $2m1label.BackColor = "Transparent"
    $2m1label.ForeColor = "Black"
    $2m1label.AutoSize = $true
    $form.Controls.Add($2m1label)

$certutillabel = New-Object System.Windows.Forms.Label
    $certutillabel.Location = New-Object System.Drawing.Size(240,25)
    $certutillabel.Text = 'Toggle CertUtil Functions'
    $certutillabel.Font = "Tahoma,9"
    $certutillabel.BackColor = "Transparent"
    $certutillabel.ForeColor = "Black"
    $certutillabel.AutoSize = $true
    $form.Controls.Add($certutillabel)

$socliblabel = New-Object System.Windows.Forms.Label
    $socliblabel.Location = New-Object System.Drawing.Size(240,5)
    $socliblabel.Text = 'Toggle Get Services'
    $socliblabel.Font = "Tahoma,9"
    $socliblabel.BackColor = "Transparent"
    $socliblabel.ForeColor = "Black"
    $socliblabel.AutoSize = $true
    $form.Controls.Add($socliblabel)

#endregion Form Labels

#region checkbox logic

$toggleButton = New-Object System.Windows.Forms.Button
    $toggleButton.Location = New-Object System.Drawing.Size(345,50)
    $toggleButton.FlatStyle = 'Popup'
    $toggleButton.Text = 'Toggle'
    $toggleButton.Font = 'Tahoma,10'
    $toggleButton.Add_Click({examine_chkbx_state})
    $form.Controls.Add($toggleButton)


function examine_chkbx_state {

    if($certchkbx.Checked -eq $true -and $objGetCert.Enabled -eq $false){
        $objGetCert.Enabled = $true
    }
    elseif($certchkbx.Checked -eq $true -and $objGetCert.Enabled -eq $true){
        $objGetCert.Enabled = $false
    }
    elseif($d2chkbx.Checked -eq $true -and $objLogButton.Enabled -eq $false){
        $objLogButton.Enabled = $true
    }
    elseif($d2chkbx.Checked -eq $true -and $objLogButton.Enabled -eq $true){
        $objLogButton.Enabled = $false
    }
    elseif($d2chkbx.Checked -eq $false -and
            $certchkbx.Checked -eq $false -and
            $m1chkbx.Checked -eq $false -and
            $2m1chkbx.Checked -eq $false -and
            $soclibchkbx.Checked -eq $false){

            [System.Windows.MessageBox]::Show('Error 01x0a002 no checkboxes selected.')
    }
    
    
  
}


#endregion checkbox logic


#region check box

$d2chkbx = New-Object System.Windows.Forms.CheckBox
    $d2chkbx.Location = New-Object System.Drawing.Size(20,7)
    $d2chkbx.BackColor = 'Transparent'
    $d2chkbx.AutoSize = $true
    $d2chkbx.ForeColor = 'Black'
    $form.Controls.Add($d2chkbx)

$soclibchkbx = New-Object System.Windows.Forms.CheckBox
    $soclibchkbx.Location = New-Object System.Drawing.Size(220,7)
    $soclibchkbx.BackColor = 'Transparent'
    $soclibchkbx.AutoSize = $true
    $soclibchkbx.ForeColor = 'Black'
    $form.Controls.Add($soclibchkbx)

$certchkbx = New-Object System.Windows.Forms.CheckBox
    $certchkbx.Location = New-Object System.Drawing.Size(220,26)
    $certchkbx.BackColor = 'Transparent'
    $certchkbx.AutoSize = $true
    $certchkbx.ForeColor = 'Black'
    $form.Controls.Add($certchkbx)

$m1chkbx = New-Object System.Windows.Forms.CheckBox
    $m1chkbx.Location = New-Object System.Drawing.Size(20,26)
    $m1chkbx.BackColor = 'Transparent'
    $m1chkbx.AutoSize = $true
    $m1chkbx.ForeColor = 'Black'
    $form.Controls.Add($m1chkbx)

$2m1chkbx = New-Object System.Windows.Forms.CheckBox
    $2m1chkbx.Location = New-Object System.Drawing.Size(20,45)
    $2m1chkbx.BackColor = 'Transparent'
    $2m1chkbx.AutoSize = $true
    $2m1chkbx.ForeColor = 'Black'
    $form.Controls.Add($2m1chkbx)



#endregion check box


#region Radio Buttons


$socButton = New-Object System.Windows.Forms.RadioButton
    $socButton.FlatStyle = 'Popup'
    $socButton.BackColor = 'Transparent'
    $socButton.AutoSize = $true
    $socButton.Location = New-Object System.Drawing.Size(420,10)
    $socButton.Add_Click({if ($socButton.Checked -eq $True){$objSOCBox.Enabled = $true
        $objServerBox.Enabled = $false 
        $objOffButton.Enabled = $true 
        $objRebootButton.Enabled = $true}})
    $form.Controls.Add($socButton)

$serverButton = New-Object System.Windows.Forms.RadioButton
    $serverButton.FlatStyle = 'Popup'
    $serverButton.BackColor = 'Transparent'
    $serverButton.AutoSize = $true
    $serverButton.Add_Click({if ($serverButton.Checked -eq $True){$objServerBox.Enabled = $true
        $objSOCBox.Enabled = $false
        $objOffButton.Enabled = $false
        $objRebootButton.Enabled = $false}})
    $serverButton.Location = New-Object System.Drawing.Size(620,10)
    $form.Controls.Add($serverButton)



#endregion Radio Buttons

#region Form Combo Box

# combobox (dropdownlist) that gains data from an array that lists all SOC client workstations as an array of strings
# allows you to select one and stores it in $objComboBox.SelectedValue and allows you to interact with that string
# using it as a computer name in this instance

$objSOCBox = New-Object System.Windows.Forms.ComboBox
    $objSOCBox.Location = New-Object System.Drawing.Size(440,5)
    $objSOCBox.DropDownStyle = "DropDownList"
    $objSOCBox.Font = "Tahoma, 10"
    $objSOCBox.Width = 160
    $objSOCBox.DataSource = $arrClients
    $objSOCBox.SelectedValue = $selectedClient
    $objSOCBox.FlatStyle = "Popup"
    $objSocBox.Enabled = $false
    $form.Controls.Add($objSOCBox)

$objServerBox = New-Object System.Windows.Forms.ComboBox
    $objServerBox.Location = New-Object System.Drawing.Size(640,5)
    $objServerBox.DropDownStyle = "DropDownList"
    $objServerBox.Font = "Tahoma, 10"
    $objServerBox.Width = 160
    $objServerBox.DataSource = $arrServers
    $objServerBox.SelectedValue = $selectedClient
    $objServerBox.FlatStyle = "Popup"
    $objServerBox.Enabled = $False
    $form.Controls.Add($objServerBox)

#endregion Form Combo Boxes

#region Form Buttons

$objClearButton = New-Object System.Windows.Forms.Button
    $objClearButton.Location = New-Object System.Drawing.Size(440,40)
    $objClearButton.Text = "Clear Logs"
    $objClearButton.Height = 35
    $objClearButton.Width = 120
    $objClearButton.FlatStyle = "Popup"
    $objClearButton.Font = "Tahoma, 9"
    $objClearButton.BackColor = "DarkGray"
    $objClearButton.Add_Click({clearLogs})
    $form.Controls.Add($objClearButton)

$objLogButton = New-Object System.Windows.Forms.Button
    $objLogButton.Location = New-Object System.Drawing.Size(560,40)
    $objLogButton.Text = "Get Event Logs"
    $objLogButton.FlatStyle = "Popup"
    $objLogButton.Height = 35
    $objLogButton.Width = 120
    $objLogButton.Font = "Tahoma, 9"
    $objLogButton.BackColor = "DarkGray"
    $objLogButton.Add_Click({getAppLogs})
    $form.Controls.Add($objLogButton)

$objGetServices = New-Object System.Windows.Forms.Button
    $objGetServices.Location = New-Object System.Drawing.Size(900,40)
    $objGetServices.Text = "Get Services"
    $objGetServices.FlatStyle = "Popup"
    $objGetServices.Height = 35
    $objGetServices.Width = 120
    $objGetServices.Font = "Tahoma, 9"
    $objGetServices.BackColor = "DarkGray"
    $objGetServices.Enabled = $true
    $objGetServices.Add_Click({get_services})
    $form.Controls.Add($objGetServices)

function get_services{
    if($serverButton.Checked -eq $true){
        $target = $objServerBox.SelectedValue
        $status = Test-Connection -ComputerName $target -Count 1 -Quiet
        if($status -eq $true){
            $services = Get-Service -ComputerName $target | 
                select -Property Name,DisplayName,Status,StartType | 
                ConvertTo-DataTable
            $appGrid.DataSource = $services
        }
        else{
        [System.Windows.MessageBox]::Show('Error 0x0a003 destination unreachable.')
        }
    }
    elseif($socButton.Checked -eq $true){
        $target = $objSOCBox.SelectedValue
        $status = Test-Connection -ComputerName $target -Count 1 -Quiet
        if($status -eq $true){
            $services = Get-Service -ComputerName $target | 
                select -Property Name,DisplayName,Status,StartType | 
                ConvertTo-DataTable
            $appGrid.DataSource = $services
        }
        else{
        [System.Windows.MessageBox]::Show('Error 0x0a003 destination unreachable.')
        }
    }
    else{
        [System.Windows.MessageBox]::Show('Error 0x0c002 no combobox selected.')
        }      
}

$objCheckPatches = New-Object System.Windows.Forms.Button
    $objCheckPatches.Location = New-Object System.Drawing.Size(1020,3)
    $objCheckPatches.Text = "RENAME ME 2"
    $objCheckPatches.FlatStyle = "Popup"
    $objCheckPatches.Height = 35
    $objCheckPatches.Width = 120
    $objCheckPatches.Font = "Tahoma, 9"
    $objCheckPatches.BackColor = "DarkGray"
    $objCheckPatches.Enabled = $false
  # $objCheckPatches.Add_Click({rebootClient})
    $form.Controls.Add($objCheckPatches)

function get_patches{



}



$objGetCert = New-Object System.Windows.Forms.Button
    $objGetCert.Location = New-Object System.Drawing.Size(900,3)
    $objGetCert.Text = "Get Local Cert"
    $objGetCert.FlatStyle = "Popup"
    $objGetCert.Height = 35
    $objGetCert.Width = 120
    $objGetCert.Font = "Tahoma, 9"
    $objGetCert.BackColor = "DarkGray"
    $objGetCert.Add_Click({Get-RemoteCerts})
    $form.Controls.Add($objGetCert)

function Get-RemoteCerts(){

if($socButton.Checked -eq $true){
$target = $objSOCBox.SelectedValue
$status = Test-Connection -ComputerName $target -Quiet
    if($status -eq $false){
        [System.Windows.MessageBox]::Show($target + 'is offline.')
    }
    else{
    $personalstore = New-Object System.Security.Cryptography.X509Certificates.X509Store("\\$target\my","LocalMachine")
        $personalstore.Open('ReadOnly')
        if($personalstore.Certificates -ne $null){
            foreach($cert in $personalstore.Certificates){
                [System.Windows.MessageBox]::Show($target + ' ' + $cert.NotAfter)
            }
        }
    }
}
elseif($serverButton.Checked -eq $true){
$target = $objServerBox.SelectedValue
$status = Test-Connection -ComputerName $target -Quiet
    if($status -eq $false){
        [System.Windows.MessageBox]::Show($target + 'is offline.')
    }
    else{
    $personalstore = New-Object System.Security.Cryptography.X509Certificates.X509Store("\\$target\my","LocalMachine")
        $personalstore.Open('ReadOnly')
        if($personalstore.Certificates -ne $null){
            foreach($cert in $personalstore.Certificates){
            [System.Windows.MessageBox]::Show($target + ' ' + $cert.NotAfter)
            }
            
        }
    }
}
else{
[System.Windows.MessageBox]::Show('Error 0x0a001 SOC Workstation combobox not selected.')
}

}

   
$objExit = New-Object System.Windows.Forms.Button
    $objExit.Location = New-Object System.Drawing.Size(1140,3)
    $objExit.Text = "Exit Application"
    $objExit.FlatStyle = "Popup"
    $objExit.Height = 35
    $objExit.Width = 120
    $objExit.Font = "Tahoma, 10"
    $objExit.BackColor = "DarkGray"
    $objExit.Enabled = $true
    $objExit.Add_Click({$form.Close()})
    $form.Controls.Add($objExit)


$objRebootButton = New-Object System.Windows.Forms.Button
    $objRebootButton.Location = New-Object System.Drawing.Size(1020,40)
    $objRebootButton.Text = "Reboot"
    $objRebootButton.FlatStyle = "Popup"
    $objRebootButton.Height = 35
    $objRebootButton.Width = 120
    $objRebootButton.Font = "Tahoma, 9"
    $objRebootButton.BackColor = "DarkGray"
    $objRebootButton.Enabled = $false
    $objRebootButton.Add_Click({rebootClient})
    $form.Controls.Add($objRebootButton)


$objOffButton = New-Object System.Windows.Forms.Button
    $objOffButton.Location = New-Object System.Drawing.Size(1140,40)
    $objOffButton.Text = "Power Off"
    $objOffButton.FlatStyle = "Popup"
    $objOffButton.Height = 35
    $objOffButton.Width = 120
    $objOffButton.Font = "Tahoma, 9"
    $objOffButton.BackColor = "DarkGray"
    $objOffButton.Enabled = $false
    $objOffButton.Add_Click({
        if($socButton.Checked -eq $false){
            [System.Windows.MessageBox]::Show('Error 0x0d0001 SOC workstation combobox not selected.')
            }
        else{
            Stop-Computer -ComputerName $objSOCBox.SelectedValue -Confirm
            [System.Windows.MessageBox]::Show($objSOCBox.SelectedValue + ' will be turned off shortly.')
            }    
    })
    $form.Controls.Add($objOffButton)

$objTestButton = New-Object System.Windows.Forms.Button
    $objTestButton.Location = New-Object System.Drawing.Size(680,40)
    $objTestButton.Text = "Test Connections"
    $objTestButton.FlatStyle = "Popup"
    $objTestButton.Height = 35
    $objTestButton.Width = 120
    $objTestButton.Font = "Tahoma, 9"
    $objTestButton.BackColor = "DarkGray"
    $objTestButton.Add_Click({onlineStatus})
    $form.Controls.Add($objTestButton)

$image = [System.Drawing.Image]::FromFile('C:\users\taylor.rodgers.adm\desktop\maintenance tool beta\properties\firefox.png')

$firefoxButton = New-Object System.Windows.Forms.Button
    $firefoxButton.Location = New-Object System.Drawing.Size(845,3)
    $firefoxButton.Image = $image
    $firefoxButton.FlatStyle = "Popup"
    $firefoxButton.Height = 50
    $firefoxButton.Width = 50
    $firefoxButton.BackColor = "Orange"
    $firefoxButton.Add_Click({open-ServerAdministrator})
    $form.Controls.Add($firefoxButton)



#endregion Form Buttons

#region Form DataGridViews

$appGrid = New-Object System.Windows.Forms.DataGridView
    $appGrid.Location = New-Object System.Drawing.Size (20,80)
    $appGrid.Height = 590
    $appGrid.Width = 400
    $appGrid.Font = 'Tahoma, 9'
    $appGrid.ColumnHeadersVisible = $True
    $appGrid.AllowUserToResizeColumns = $true
    $appGrid.AllowUserToAddRows = $false
    $appGrid.AllowUserToResizeRows = $true
    $appGrid.RowHeadersVisible = $false
    $form.Controls.Add($appGrid)

$sysGrid = New-Object System.Windows.Forms.DataGridView
    $sysGrid.Location = New-Object System.Drawing.Size (440,80)
    $sysGrid.Height = 590
    $sysGrid.Width = 400
    $sysGrid.Font = 'Tahoma, 9'
    $sysGrid.ColumnHeadersVisible = $True
    $sysGrid.AllowUserToResizeColumns = $true
    $sysGrid.AllowUserToAddRows = $false
    $sysGrid.AllowUserToResizeRows = $true
    $sysGrid.RowHeadersVisible = $false
    $form.Controls.Add($sysGrid)

$secGrid = New-Object System.Windows.Forms.DataGridView
    $secGrid.Location = New-Object System.Drawing.Size (860,80)
    $secGrid.Height = 590
    $secGrid.Width = 400
    $secGrid.Font = 'Tahoma, 9'
    $secGrid.ColumnHeadersVisible = $True
    $secGrid.AllowUserToResizeColumns = $true
    $secGrid.AllowUserToAddRows = $false
    $secGrid.AllowUserToResizeRows = $true
    $secGrid.RowHeadersVisible = $false
    $form.Controls.Add($secGrid)

#endregion Form Text Boxes



# Function to query the string that is selected in $objComboBox and get its event logs then output them into rich texts box with set width dimensions for readability.
# You can customize the -newest values in order to not get the out of bounds error. Some workstations that do not get accessed often will have errors when accessing 
# security logs that are older than a certain amount of days. In the event you get this error just lower the number of -newest logs.

#region Functions

function onlineStatus()
{
    $statusarray = @(0,0)
    Write-Host ' '
    if($socButton.Checked -eq $true){

        foreach($client in $arrClients)
        {
            $status = Test-Connection -Count 1 -ComputerName $client -Quiet
            if($status -eq "True")
            {
            Write-Host "$client is online. " -ForegroundColor Green
            $statusarray[1] += 1
            }
            else
            {
            Write-Host -ForegroundColor Red "$client is offline. "
            $statusarray[0] += 1
            } 
        }
        [System.Windows.MessageBox]::Show("There are " + $statusarray[1] + " workstations online, and " + $statusarray[0] + " workstations offline. Check posh console for more detailed information.")
    }
    elseif($serverButton.Checked -eq $true){
        foreach($server in $arrServers)
        {
            $status = Test-Connection -Count 1 -ComputerName $server -Quiet
            if($status -eq "True")
            {
            Write-Host "$server is online. " -ForegroundColor Green
            $statusarray[1] += 1
            }
            else
            {
            Write-Host -ForegroundColor Red "$server is offline. "
            $statusarray[0] += 1
            }
         }
      [System.Windows.MessageBox]::Show("There are " + $statusarray[1] + " servers online, and " + $statusarray[0] + " servers offline. Check posh console for more detailed information.")
     }
     else{
      [System.Windows.MessageBox]::Show('Please select the radio button for either servers or SOC workstations and try again.') 
     }
  
}




function open-ServerAdministrator(){
    if($socButton.Checked -eq $false){
        [System.Windows.MessageBox]::Show('Please select a SOC workstation.')
    }
    else{
        $target = $objSOCBox.SelectedValue
        & 'C:\Program Files\Mozilla Firefox\firefox.exe' https://$target`:1311
    }
}



function getAppLogs()

{
    if($socButton.Checked -eq $false){
        [System.Windows.MessageBox]::Show('Please select a SOC workstation')
    }
    else{

        $applogs = Get-EventLog -ComputerName $objSOCBox.SelectedValue -LogName Application -EntryType Error,Warning -Newest 25 |
            select Index,EntryType,TimeGenerated,Source,Message |
            ConvertTo-DataTable 
            $appGrid.DataSource = $applogs

        $systemLogs = Get-EventLog -ComputerName $objSOCBox.SelectedValue -LogName System -EntryType Error,Warning -Newest 25 |
            select Index,EntryType,TimeGenerated,Source,Message |
            ConvertTo-DataTable 
            $sysGrid.DataSource = $systemLogs

        $securityLogs = Get-EventLog -ComputerName $objSOCBox.SelectedValue -LogName Security -EntryType FailureAudit -Newest 100 |
            select Index,EntryType,TimeGenerated,Message |
            ConvertTo-DataTable 
            $secGrid.DataSource = $securityLogs
    }
}

# function to clear the contents of the check box to avoid overwrite issues when getting event logs of a new workstation.

function clearLogs()
{
# Clear content of all data grid views
$appGrid.DataSource = $null
$sysGrid.DataSource = $null
$secGrid.DataSource = $null
}



# function to reboot target client

function rebootClient()
{
Restart-Computer -ComputerName $objComboBox.SelectedValue -Confirm
[System.Windows.MessageBox]::Show("Rebooting " + $objComboBox.SelectedValue + " please wait...")
}

# function to turn off target client
function offClient()
{
Stop-Computer -ComputerName $objComboBox.SelectedValue -Confirm 
[System.Windows.MessageBox]::Show("Shutting down " + $objComboBox.SelectedValue + " please wait...")
}


#endregion


##############################
# ENTRY POINT OF FORM HERE   #
##############################

[void] $form.ShowDialog()