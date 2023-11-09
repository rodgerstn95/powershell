[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")


function Intilialize-Script(){

$cred = Get-Credential -Message 'Please type domain administrator credentials'
$session = New-PSSession -ComputerName 'NFEYOCNDDCS1' -Credential ($cred)

Invoke-Command $session -scriptblock {Import-Module ActiveDirectory} | out-null
Import-PSSession -Session $session -Module ActiveDirectory -AllowClobber | out-null

}

Intilialize-Script

$form = New-Object System.Windows.Forms.Form;
    $form.text = "Active Directory Account Tool";
    $form.Size = New-Object System.Drawing.Size(1280,720);
    $form.FormBorderStyle = "FixedDialog";
    $form.ControlBox = $true;
    $form.MinimizeBox = $true;
    $form.MaximizeBox = $false;
    $form.SizeGripStyle = "Hide";
    $form.BackColor = 'LightGray';
    $form.StartPosition = "CenterScreen";


$objSOCBox = New-Object System.Windows.Forms.ComboBox;
    $objSOCBox.Location = New-Object System.Drawing.Size(440,5);
    $objSOCBox.DropDownStyle = "DropDownList";
    $objSOCBox.Font = "Tahoma, 10";
    $objSOCBox.Width = 160;
    $objSOCBox.DataSource = $arrClients;
    $objSOCBox.SelectedValue = $selectedClient;
    $objSOCBox.FlatStyle = "Popup";
    $objSocBox.Enabled = $false;
    $form.Controls.Add($objSOCBox);





$form.ShowDialog();
