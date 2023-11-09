[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.MessageBox");

$vers = "1.0"
$class = "UNCLASS"

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



# $users_ou_array = Get-ADOrganizationalUnit -Filter * -SearchBase 'OU=User Accounts,OU=Users,OU=CNDS,DC=feyo,DC=onenet,DC=oob,DC=navy,DC=mil' |
   # select -ExpandProperty SamAccountName

$svc_ou_array = Get-ADUser -Filter * -SearchBase $replaceMe |
    select -ExpandProperty SamAccountName;

$domain_ou_array = Get-ADUser -Filter * -SearchBase $replaceMe |
    select -ExpandProperty SamAccountName;

$aaa_ou_array = Get-ADUser -Filter * -SearchBase $replaceMe |
    select -ExpandProperty SamAccountName;

$splunk_ou_array = Get-ADUser -Filter * -SearchBase $replaceMe |
    select -ExpandProperty SamAccountName;

# $acas_ou_array = Get-ADOrganizationalUnit -Filter * -SearchBase $replaceMe |
   # select -ExpandProperty SamAccountName;

$usr_ou_array = Get-ADUser -Filter * -SearchBase $replaceMe |
    select -ExpandProperty SamAccountName;

$pus_ou_array = Get-ADUser -Filter * -SearchBase $replaceMe |
    select -ExpandProperty SamAccountName;

$admins_ou_array = Get-ADUser -Filter * -SearchBase $replaceMe |
    select -ExpandProperty SamAccountName;




$form = New-Object System.Windows.Forms.Form;
    $form.Size = New-Object System.Drawing.Size(270,500);
    $form.FormBorderStyle = "FixedDialog";
    $form.Font = 'ArialNarrow, 9';
    $form.text = "ADTool $vers $class";
    $form.ControlBox = $true;
    $form.MinimizeBox = $true;
    $form.MaximizeBox = $false;
    $form.add_FormClosing({Remove-PSSession -Session $session;
                           Write-Host 'Closed DCS1 PSSession.'; });
   #$form.SizeGripStyle = "Hide";
    $form.BackColor = 'LightBlue';
    $form.StartPosition = "CenterScreen";

$tabcontrol = New-Object System.Windows.Forms.TabControl;
    $tabcontrol.Location = New-Object System.Drawing.Size(1,1);
    $tabcontrol.Size = New-Object System.Drawing.Size(270,500);
    $tabcontrol.Alignment = 'Left';
    $tabcontrol.BackColor = 'Green';    
    # Add tab control to form
    $form.Controls.Add($tabcontrol);

    
    # svc_tab
    $svc_tab = New-Object System.Windows.Forms.TabPage;
        $svc_tab.Text = 'Service Accounts';
        $tabcontrol.Controls.Add($svc_tab);
    $svc_box = New-Object System.Windows.Forms.ComboBox;
        $svc_box.Location = New-Object System.Drawing.Size(10,5);
        $svc_box.DropDownStyle = "DropDownList";
        $svc_box.Font = "Tahoma, 10";
        $svc_box.Width = 160;
        $svc_box.DataSource = $svc_ou_array;
        $svc_box.FlatStyle = "Popup";
        $svc_box.Enabled = $true;
    $svc_button1 = New-Object System.Windows.Forms.Button;
        $svc_button1.Height = 30;
        $svc_button1.Width = 65;
        $svc_button1.Location = New-Object System.Drawing.Size(10,430);
        $svc_button1.Text = 'Unlock';
        $svc_button1.FlatStyle = 'Popup';
        $svc_button1.Enabled = $false;
      # $svc_button1.Add_Click({

      #     Unlock-ADAccount -Identity $svcbox.SelectedValue;
      #     [System.Windows.MessageBox]::Show($svcbox.SelectedValue + ' has been unlocked.');

      # })
    $svc_tab.Controls.Add($svc_button1);

    $svc_button2 = New-Object System.Windows.Forms.Button;
        $svc_button2.Height = 30;
        $svc_button2.Width = 65;
        $svc_button2.Location = New-Object System.Drawing.Size(75,430);
        $svc_button2.Text = 'Reset';
        $svc_button2.FlatStyle = 'Popup';
        $svc_button2.Enabled = $false;
    $svc_tab.Controls.Add($svc_button2);

    $svc_button3 = New-Object System.Windows.Forms.Button;
        $svc_button3.Height = 30;
        $svc_button3.Width = 65;
        $svc_button3.Location = New-Object System.Drawing.Size(135,430);
        $svc_button3.Text = 'Disable';
        $svc_button3.FlatStyle = 'Popup';
        $svc_button3.Enabled = $false;
    $svc_tab.Controls.Add($svc_button3);
    $svc_tab.Controls.Add($svc_box);

    $svc_label = New-Object System.Windows.Forms.Label;
        $svc_label.Location = New-Object System.Drawing.Size(15,40);
        $svc_label.Width = 200;
        $svc_label.Height = 200;
        $svc_label.Text = 'Do not modify service accounts with this tool.';
    $svc_tab.Controls.Add($svc_label);
    

    # admins_tab
    $admins_tab = New-Object System.Windows.Forms.TabPage;
        $admins_tab.Text = 'Admins';
        $admins_tab.BackColor = 'LightGreen';
        $tabcontrol.Controls.Add($admins_tab);
    $admins_box = New-Object System.Windows.Forms.ComboBox;
        $admins_box.Location = New-Object System.Drawing.Size(10,5);
        $admins_box.DropDownStyle = "DropDownList";
        $admins_box.Font = "Tahoma, 10";
        $admins_box.Width = 160;
        $admins_box.DataSource = $admins_ou_array;
        $admins_box.FlatStyle = "Popup";
        $admins_box.Enabled = $true;
    $admins_button1 = New-Object System.Windows.Forms.Button;
        $admins_button1.Height = 30;
        $admins_button1.Width = 65;
        $admins_button1.Location = New-Object System.Drawing.Size(10,430);
        $admins_button1.Text = 'Unlock';
        $admins_button1.FlatStyle = 'Popup';
        $admins_button1.Add_Click({

            Unlock-ADAccount -Identity $admins_box.SelectedValue;
            [System.Windows.MessageBox]::Show($admins_box.SelectedValue + ' has been unlocked.');

        });
    $admins_tab.Controls.Add($admins_button1);

    $admins_button2 = New-Object System.Windows.Forms.Button;
        $admins_button2.Height = 30;
        $admins_button2.Width = 65;
        $admins_button2.Location = New-Object System.Drawing.Size(75,430);
        $admins_button2.Text = 'Reset';
        $admins_button2.FlatStyle = 'Popup';
        $admins_button2.Add_Click({

            Set-ADAccountPassword -Identity $admins_box.SelectedValue -Reset;
            [System.Windows.MessageBox]::Show($admins_box.SelectedValue + ' has been reset.');
            

        });
    $admins_tab.Controls.Add($admins_button2);

    $admins_button3 = New-Object System.Windows.Forms.Button;
        $admins_button3.Height = 30;
        $admins_button3.Width = 65;
        $admins_button3.Location = New-Object System.Drawing.Size(135,430);
        $admins_button3.Text = 'Disable';
        $admins_button3.FlatStyle = 'Popup';
        $admins_button3.Add_Click({

            Disable-ADAccount -identity $admins_box.SelectedValue;
            [System.Windows.MessageBox]::Show($admins_box.SelectedValue + ' has been disabled.');

        });
    $admins_tab.Controls.Add($admins_button3);
    $admins_tab.Controls.Add($admins_box);
    

    # domain_tab
    $domain_tab = New-Object System.Windows.Forms.TabPage;
        $domain_tab.Text = 'Domain Admins';
        $tabcontrol.Controls.Add($domain_tab);
    $domain_box = New-Object System.Windows.Forms.ComboBox;
        $domain_box.Location = New-Object System.Drawing.Size(10,5);
        $domain_box.DropDownStyle = "DropDownList";
        $domain_box.Font = "Tahoma, 10";
        $domain_box.Width = 160;
        $domain_box.DataSource = $domain_ou_array;
        $domain_box.FlatStyle = "Popup";
        $domain_box.Enabled = $true;
    $domain_button1 = New-Object System.Windows.Forms.Button;
        $domain_button1.Height = 30;
        $domain_button1.Width = 65;
        $domain_button1.Location = New-Object System.Drawing.Size(10,430);
        $domain_button1.Text = 'Unlock';
        $domain_button1.FlatStyle = 'Popup';
        $domain_button1.Add_Click({

            Unlock-ADAccount -Identity $domain_box.SelectedValue;
            [System.Windows.MessageBox]::Show($domain_box.SelectedValue + ' has been unlocked.');

        });
    $domain_tab.Controls.Add($domain_button1);

    $domain_button2 = New-Object System.Windows.Forms.Button;
        $domain_button2.Height = 30;
        $domain_button2.Width = 65;
        $domain_button2.Location = New-Object System.Drawing.Size(75,430);
        $domain_button2.Text = 'Reset';
        $domain_button2.FlatStyle = 'Popup';
        $domain_button2.Add_Click({

            Set-ADAccountPassword -Identity $domain_box.SelectedValue -Reset;
            [System.Windows.MessageBox]::Show($domain_box.SelectedValue + ' has been reset.');
            

        });
    $domain_tab.Controls.Add($domain_button2);

    $domain_button3 = New-Object System.Windows.Forms.Button;
        $domain_button3.Height = 30;
        $domain_button3.Width = 65;
        $domain_button3.Location = New-Object System.Drawing.Size(135,430);
        $domain_button3.Text = 'Disable';
        $domain_button3.FlatStyle = 'Popup';
        $domain_button3.Add_Click({

            Disable-ADAccount -identity $domain_box.SelectedValue;
            [System.Windows.MessageBox]::Show($domain_box.SelectedValue + ' has been disabled.');

        });
    $domain_tab.Controls.Add($domain_button3);
    $domain_tab.Controls.Add($domain_box);

    
    # aaa_tab
    $aaa_tab = New-Object System.Windows.Forms.TabPage;
        $aaa_tab.Text = 'AAA Users';
        $tabcontrol.Controls.Add($aaa_tab);
    $aaa_box = New-Object System.Windows.Forms.ComboBox;
        $aaa_box.Location = New-Object System.Drawing.Size(10,5);
        $aaa_box.DropDownStyle = "DropDownList";
        $aaa_box.Font = "Tahoma, 10";
        $aaa_box.Width = 160;
        $aaa_box.DataSource = $aaa_ou_array;
        $aaa_box.FlatStyle = "Popup";
        $aaa_box.Enabled = $true;
    $aaa_button1 = New-Object System.Windows.Forms.Button;
        $aaa_button1.Height = 30;
        $aaa_button1.Width = 65;
        $aaa_button1.Location = New-Object System.Drawing.Size(10,430);
        $aaa_button1.Text = 'Unlock';
        $aaa_button1.FlatStyle = 'Popup';
        $aaa_button1.Add_Click({

            Unlock-ADAccount -Identity $aaa_box.SelectedValue;
            [System.Windows.MessageBox]::Show($aaa_box.SelectedValue + ' has been unlocked.');

        });
    $aaa_tab.Controls.Add($aaa_button1);

    $aaa_button2 = New-Object System.Windows.Forms.Button;
        $aaa_button2.Height = 30;
        $aaa_button2.Width = 65;
        $aaa_button2.Location = New-Object System.Drawing.Size(75,430);
        $aaa_button2.Text = 'Reset';
        $aaa_button2.FlatStyle = 'Popup';
        $aaa_button2.Add_Click({

            Set-ADAccountPassword -Identity $aaa_box.SelectedValue -Reset;
            [System.Windows.MessageBox]::Show($aaa_box.SelectedValue + ' has been reset.');
            

        });
    $aaa_tab.Controls.Add($aaa_button2);

    $aaa_button3 = New-Object System.Windows.Forms.Button;
        $aaa_button3.Height = 30;
        $aaa_button3.Width = 65;
        $aaa_button3.Location = New-Object System.Drawing.Size(135,430);
        $aaa_button3.Text = 'Disable';
        $aaa_button3.FlatStyle = 'Popup';
        $aaa_button3.Add_Click({

            Disable-ADAccount -identity $aaa_box.SelectedValue;
            [System.Windows.MessageBox]::Show($aaa_box.SelectedValue + ' has been disabled.');

        });
    $aaa_tab.Controls.Add($aaa_button3);
    $aaa_tab.Controls.Add($aaa_box);
    

    # splunk_tab
    $splunk_tab = New-Object System.Windows.Forms.TabPage;
        $splunk_tab.Text = 'NCDOC_Splunk_Admins';
        $tabcontrol.Controls.Add($splunk_tab);
    $splunk_box = New-Object System.Windows.Forms.ComboBox;
        $splunk_box.Location = New-Object System.Drawing.Size(10,5);
        $splunk_box.DropDownStyle = "DropDownList";
        $splunk_box.Font = "Tahoma, 10";
        $splunk_box.Width = 160;
        $splunk_box.DataSource = $splunk_ou_array;
        $splunk_box.FlatStyle = "Popup";
        $splunk_box.Enabled = $true;
    $splunk_button1 = New-Object System.Windows.Forms.Button;
        $splunk_button1.Height = 30;
        $splunk_button1.Width = 65;
        $splunk_button1.Location = New-Object System.Drawing.Size(10,430);
        $splunk_button1.Text = 'Unlock';
        $splunk_button1.FlatStyle = 'Popup';
        $splunk_button1.Add_Click({

            Unlock-ADAccount -Identity $splunk_box.SelectedValue;
            [System.Windows.MessageBox]::Show($splunk_box.SelectedValue + ' has been unlocked.');

        });
    $splunk_tab.Controls.Add($splunk_button1);

    $splunk_button2 = New-Object System.Windows.Forms.Button;
        $splunk_button2.Height = 30;
        $splunk_button2.Width = 65;
        $splunk_button2.Location = New-Object System.Drawing.Size(75,430);
        $splunk_button2.Text = 'Reset';
        $splunk_button2.FlatStyle = 'Popup';
        $splunk_button2.Add_Click({

            Set-ADAccountPassword -Identity $splunk_box.SelectedValue -Reset;
            [System.Windows.MessageBox]::Show($splunk_box.SelectedValue + ' has been reset.');
            

        });
    $splunk_tab.Controls.Add($splunk_button2);

    $splunk_button3 = New-Object System.Windows.Forms.Button;
        $splunk_button3.Height = 30;
        $splunk_button3.Width = 65;
        $splunk_button3.Location = New-Object System.Drawing.Size(135,430);
        $splunk_button3.Text = 'Disable';
        $splunk_button3.FlatStyle = 'Popup';
        $splunk_button3.Add_Click({

            Disable-ADAccount -identity $splunk_box.SelectedValue;
            [System.Windows.MessageBox]::Show($splunk_box.SelectedValue + ' has been disabled.');

        });
    $splunk_tab.Controls.Add($splunk_button3);
    $splunk_tab.Controls.Add($splunk_box);
    

    # usr_tab
    $usr_tab = New-Object System.Windows.Forms.TabPage;
        $usr_tab.Text = 'User Accounts';
        $tabcontrol.Controls.Add($usr_tab);
    $usr_box = New-Object System.Windows.Forms.ComboBox;
        $usr_box.Location = New-Object System.Drawing.Size(10,5);
        $usr_box.DropDownStyle = "DropDownList";
        $usr_box.Font = "Tahoma, 10";
        $usr_box.Width = 160;
        $usr_box.DataSource = $usr_ou_array;
        $usr_box.FlatStyle = "Popup";
        $usr_box.Enabled = $true;
    $usr_button1 = New-Object System.Windows.Forms.Button;
        $usr_button1.Height = 30;
        $usr_button1.Width = 65;
        $usr_button1.Location = New-Object System.Drawing.Size(10,430);
        $usr_button1.Text = 'Unlock';
        $usr_button1.FlatStyle = 'Popup';
        $usr_button1.Add_Click({

            Unlock-ADAccount -Identity $usr_box.SelectedValue;
            [System.Windows.MessageBox]::Show($usr_box.SelectedValue + ' has been unlocked.');

        });
    $usr_tab.Controls.Add($usr_button1);

    $usr_button2 = New-Object System.Windows.Forms.Button;
        $usr_button2.Height = 30;
        $usr_button2.Width = 65;
        $usr_button2.Location = New-Object System.Drawing.Size(75,430);
        $usr_button2.Text = 'Reset';
        $usr_button2.FlatStyle = 'Popup';
        $usr_button2.Add_Click({

            Set-ADAccountPassword -Identity $usr_box.SelectedValue -Reset;
            [System.Windows.MessageBox]::Show($usr_box.SelectedValue + ' has been reset.');
            

        });
    $usr_tab.Controls.Add($usr_button2);

    $usr_button3 = New-Object System.Windows.Forms.Button;
        $usr_button3.Height = 30;
        $usr_button3.Width = 65;
        $usr_button3.Location = New-Object System.Drawing.Size(135,430);
        $usr_button3.Text = 'Disable';
        $usr_button3.FlatStyle = 'Popup';
        $usr_button3.Add_Click({

            Disable-ADAccount -identity $usr_box.SelectedValue;
            [System.Windows.MessageBox]::Show($usr_box.SelectedValue + ' has been disabled.');

        });
    $usr_tab.Controls.Add($usr_button3);
    $usr_tab.Controls.Add($usr_box);

    # pus_tab
    $pus_tab = New-Object System.Windows.Forms.TabPage;
        $pus_tab.Text = 'PUS Admins';
        $tabcontrol.Controls.Add($pus_tab);
    $pus_box = New-Object System.Windows.Forms.ComboBox;
        $pus_box.Location = New-Object System.Drawing.Size(10,5);
        $pus_box.DropDownStyle = "DropDownList";
        $pus_box.Font = "Tahoma, 10";
        $pus_box.Width = 160;
        $pus_box.DataSource = $pus_ou_array;
        $pus_box.FlatStyle = "Popup";
        $pus_box.Enabled = $true;

    $pus_button1 = New-Object System.Windows.Forms.Button;
        $pus_button1.Height = 30;
        $pus_button1.Width = 65;
        $pus_button1.Location = New-Object System.Drawing.Size(10,430);
        $pus_button1.Text = 'Unlock';
        $pus_button1.FlatStyle = 'Popup';
        $pus_button1.Add_Click({

            Unlock-ADAccount -Identity $pus_box.SelectedValue;
            [System.Windows.MessageBox]::Show($pus_box.SelectedValue + ' has been unlocked.');

        });
    $pus_tab.Controls.Add($pus_button1);

    $pus_button2 = New-Object System.Windows.Forms.Button;
        $pus_button2.Height = 30;
        $pus_button2.Width = 65;
        $pus_button2.Location = New-Object System.Drawing.Size(75,430);
        $pus_button2.Text = 'Reset';
        $pus_button2.FlatStyle = 'Popup';
        $pus_button2.Add_Click({

            Set-ADAccountPassword -Identity $pus_box.SelectedValue -Reset;
            [System.Windows.MessageBox]::Show($pus_box.SelectedValue + ' has been reset.');
            

        });
    $pus_tab.Controls.Add($pus_button2);

    $pus_button3 = New-Object System.Windows.Forms.Button;
        $pus_button3.Height = 30;
        $pus_button3.Width = 65;
        $pus_button3.Location = New-Object System.Drawing.Size(135,430);
        $pus_button3.Text = 'Disable';
        $pus_button3.FlatStyle = 'Popup';
        $pus_button3.Add_Click({

            Disable-ADAccount -identity $pus_box.SelectedValue;
            [System.Windows.MessageBox]::Show($pus_box.SelectedValue + ' has been disabled.');

        });
    $pus_tab.Controls.Add($pus_button3);
    $pus_tab.Controls.Add($pus_box);


#######################
#   ENTRY POINT HERE  #
#######################

$form.ShowDialog();
