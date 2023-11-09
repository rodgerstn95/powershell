Get-WmiObject -Class Win32_UserAccount -ComputerName $replaceMe -Property * |
 select Name,Disabled,PasswordExpires;
